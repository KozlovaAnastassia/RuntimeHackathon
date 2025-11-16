import Foundation

enum ApiError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case serverError(Int)
    case unauthorized
    case forbidden
    case notFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .noData:
            return "Нет данных"
        case .decodingError:
            return "Ошибка декодирования данных"
        case .networkError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .serverError(let code):
            return "Ошибка сервера: \(code)"
        case .unauthorized:
            return "Не авторизован"
        case .forbidden:
            return "Доступ запрещен"
        case .notFound:
            return "Ресурс не найден"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

class ApiClient {
    static let shared = ApiClient()
    
    private let baseURL = "https://api.runtimehackathon.com/v1"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Основные HTTP методы
    func get<T: Codable>(_ endpoint: String, parameters: [String: Any]? = nil) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + endpoint)
        
        if let parameters = parameters {
            urlComponents?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let url = urlComponents?.url else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try await performRequest(request)
    }
    
    func post<T: Codable, U: Codable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw ApiError.decodingError
        }
        
        return try await performRequest(request)
    }
    
    func put<T: Codable, U: Codable>(_ endpoint: String, body: U) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw ApiError.decodingError
        }
        
        return try await performRequest(request)
    }
    
    func delete(_ endpoint: String) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                throw ApiError.unauthorized
            case 403:
                throw ApiError.forbidden
            case 404:
                throw ApiError.notFound
            case 500...599:
                throw ApiError.serverError(httpResponse.statusCode)
            default:
                throw ApiError.unknown
            }
        }
    }
    
    // MARK: - Приватные методы
    private func performRequest<T: Codable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        return try JSONDecoder().decode(T.self, from: data)
                    } catch {
                        throw ApiError.decodingError
                    }
                case 401:
                    throw ApiError.unauthorized
                case 403:
                    throw ApiError.forbidden
                case 404:
                    throw ApiError.notFound
                case 500...599:
                    throw ApiError.serverError(httpResponse.statusCode)
                default:
                    throw ApiError.unknown
                }
            } else {
                throw ApiError.unknown
            }
        } catch let error as ApiError {
            throw error
        } catch {
            throw ApiError.networkError(error)
        }
    }
}

// MARK: - Расширения для работы с датами
extension JSONDecoder {
    static func withCustomDateDecoding() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}

extension JSONEncoder {
    static func withCustomDateEncoding() -> JSONEncoder {
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(formatter)
        return encoder
    }
}
