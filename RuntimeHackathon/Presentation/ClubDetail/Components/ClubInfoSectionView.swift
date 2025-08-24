import SwiftUI

struct ClubInfoSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(ClubInfoMock.sectionTitle)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(ClubInfoMock.clubDescription)
                .font(.body)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(ClubInfoMock.locationTitle)
                        .font(.headline)
                    Text(ClubInfoMock.meetingLocation)
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(ClubInfoMock.timeTitle)
                        .font(.headline)
                    Text(ClubInfoMock.meetingTime)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ClubInfoSectionView()
}
