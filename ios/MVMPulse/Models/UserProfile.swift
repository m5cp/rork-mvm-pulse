import Foundation

nonisolated enum UserRole: String, Codable, CaseIterable, Sendable {
    case businessOwner = "Business Owner"
    case employee = "Employee"
    case individual = "Individual"
    case student = "Student"
}

nonisolated enum Industry: String, Codable, CaseIterable, Sendable {
    case technology = "Technology"
    case healthcare = "Healthcare"
    case finance = "Finance"
    case manufacturing = "Manufacturing"
    case retail = "Retail"
    case government = "Government"
    case education = "Education"
    case realEstate = "Real Estate"
    case legal = "Legal"
    case professionalServices = "Professional Services"
    case other = "Other"
}

nonisolated enum CompanySize: String, Codable, CaseIterable, Sendable {
    case solo = "Solo"
    case tinyTeam = "1-10"
    case smallTeam = "11-50"
    case mediumTeam = "51-200"
    case largeTeam = "201-1000"
    case enterprise = "1000+"
}

nonisolated struct UserProfile: Codable, Sendable {
    var firstName: String = ""
    var role: UserRole = .individual
    var industry: Industry = .technology
    var companySize: CompanySize = .solo
    var email: String = ""
    var hasCompletedOnboarding: Bool = false
}
