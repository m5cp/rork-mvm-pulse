import SwiftUI

struct TeamAssessmentView: View {
    let storage: StorageService
    let store: StoreViewModel
    @State private var showAddMember: Bool = false
    @State private var showSimulateSheet: Bool = false
    @State private var selectedMember: TeamMember?
    @Environment(\.dismiss) private var dismiss

    private var teamData: TeamAssessmentData? {
        storage.teamData
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                if let data = teamData {
                    if !data.completedMembers.isEmpty {
                        teamOverviewCard(data: data)
                        alignmentGapsCard(data: data)
                    }

                    membersSection(data: data)

                    if data.members.count < TeamAssessmentData.maxMembers {
                        addMemberButton
                    }
                } else {
                    setupTeamCard
                }

                consultationCTA
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Team Assessment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .sheet(isPresented: $showAddMember) {
            NavigationStack {
                AddTeamMemberView(storage: storage)
            }
        }
        .sheet(item: $selectedMember) { member in
            NavigationStack {
                SimulateTeamMemberView(storage: storage, member: member)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 36))
                .foregroundStyle(PulseTheme.primaryTeal)

            Text("Team Pulse Assessment")
                .font(.title3.bold())

            Text("Invite up to \(TeamAssessmentData.maxMembers) team members to take the assessment independently. Compare scores to identify alignment gaps between owner and team perception.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(PulseTheme.primaryTeal.opacity(0.06))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func teamOverviewCard(data: TeamAssessmentData) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Team Overview")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(data.completedMembers.count)/\(data.members.count) completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let avgScore = data.averageScore, let ownerScore = storage.latestResult?.overallScore {
                HStack(spacing: 24) {
                    VStack(spacing: 4) {
                        Text("\(Int(ownerScore))")
                            .font(.title.bold())
                            .foregroundStyle(PulseTheme.scoreColor(for: ownerScore))
                        Text("Your Score")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text("\(Int(avgScore))")
                            .font(.title.bold())
                            .foregroundStyle(PulseTheme.scoreColor(for: avgScore))
                        Text("Team Avg")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    let gap = abs(ownerScore - avgScore)
                    VStack(spacing: 4) {
                        Text("\(Int(gap))")
                            .font(.title.bold())
                            .foregroundStyle(gap > 10 ? .orange : .green)
                        Text("Gap")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                if gap(ownerScore, avgScore) > 10 {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("Significant perception gap detected. This often signals misalignment between leadership vision and team experience.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func gap(_ a: Double, _ b: Double) -> Double {
        abs(a - b)
    }

    private func alignmentGapsCard(data: TeamAssessmentData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Alignment Gaps")
                    .font(.subheadline.bold())
            }

            ForEach(AssessmentCategory.allCases, id: \.self) { category in
                if let gapValue = data.alignmentGap(for: category) {
                    let catColor = PulseTheme.categoryColor(for: category)
                    let ownerScore = storage.latestResult?.categoryScores.first(where: { $0.category == category })?.normalizedScore ?? 0
                    let teamAvg = data.categoryAverage(for: category) ?? 0

                    HStack(spacing: 10) {
                        Image(systemName: category.icon)
                            .font(.caption2)
                            .foregroundStyle(catColor)
                            .frame(width: 16)

                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 100, alignment: .leading)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 12) {
                            Text("You: \(Int(ownerScore))")
                                .font(.caption2.bold())
                                .foregroundStyle(catColor)

                            Text("Team: \(Int(teamAvg))")
                                .font(.caption2.bold())
                                .foregroundStyle(.secondary)

                            let gapInt = Int(gapValue)
                            Text("\(gapInt)pt gap")
                                .font(.caption2.bold())
                                .foregroundStyle(gapInt > 15 ? .red : gapInt > 8 ? .orange : .green)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func membersSection(data: TeamAssessmentData) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.rectangle.stack")
                    .foregroundStyle(PulseTheme.primaryTeal)
                Text("Team Members")
                    .font(.subheadline.bold())
                Spacer()
            }

            ForEach(data.members) { member in
                memberRow(member: member)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func memberRow(member: TeamMember) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(member.hasCompleted ? PulseTheme.primaryTeal.opacity(0.15) : Color(.tertiarySystemFill))
                    .frame(width: 36, height: 36)
                Text(String(member.name.prefix(1)).uppercased())
                    .font(.subheadline.bold())
                    .foregroundStyle(member.hasCompleted ? PulseTheme.primaryTeal : .secondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline.bold())
                Text(member.role)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if member.hasCompleted, let score = member.overallScore {
                Text("\(Int(score))")
                    .font(.subheadline.bold())
                    .foregroundStyle(PulseTheme.scoreColor(for: score))
            } else {
                Button {
                    selectedMember = member
                } label: {
                    Text("Simulate")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(PulseTheme.primaryTeal.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var addMemberButton: some View {
        Button {
            showAddMember = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Add Team Member")
                    .font(.subheadline.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.bordered)
        .tint(PulseTheme.primaryTeal)
    }

    private var setupTeamCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 36))
                .foregroundStyle(PulseTheme.primaryTeal.opacity(0.5))

            Text("No team members yet")
                .font(.subheadline.bold())

            Text("Add team members to compare their assessment results with yours. See where your team aligns and where perception gaps exist.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                if storage.teamData == nil {
                    storage.teamData = TeamAssessmentData(members: [], teamName: "\(storage.userProfile.firstName)'s Team")
                }
                showAddMember = true
            } label: {
                Text("Add First Member")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(PulseTheme.primaryTeal)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var consultationCTA: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                Text("Want deeper team analysis?")
                    .font(.subheadline.bold())
            }

            Text("M5CAIRO offers facilitated team alignment workshops based on Pulse data. Identify blind spots, build consensus, and create shared action plans.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let url = URL(string: "mailto:contact@m5cairo.com?subject=Team%20Alignment%20Workshop") {
                Link(destination: url) {
                    Text("Contact for Pricing")
                        .font(.caption.bold())
                        .foregroundStyle(PulseTheme.primaryTeal)
                }
            }
        }
        .padding(16)
        .background(PulseTheme.primaryTeal.opacity(0.04))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(PulseTheme.primaryTeal.opacity(0.1), lineWidth: 1)
        )
    }
}

struct AddTeamMemberView: View {
    let storage: StorageService
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var role: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Member Details") {
                TextField("Name", text: $name)
                    .textContentType(.name)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                TextField("Role / Title", text: $role)
            }

            Section {
                Text("Team members will need to take the assessment on their own device. You can simulate their scores here for planning purposes, or share the app link for them to complete independently.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Add Member")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    let member = TeamMember(
                        id: UUID().uuidString,
                        name: name.trimmingCharacters(in: .whitespaces),
                        email: email.trimmingCharacters(in: .whitespaces),
                        role: role.trimmingCharacters(in: .whitespaces),
                        invitedDate: Date(),
                        hasCompleted: false,
                        categoryScores: nil,
                        overallScore: nil,
                        completedDate: nil
                    )
                    if storage.teamData == nil {
                        storage.teamData = TeamAssessmentData(members: [member], teamName: "\(storage.userProfile.firstName)'s Team")
                    } else {
                        storage.teamData?.members.append(member)
                    }
                    dismiss()
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}

struct SimulateTeamMemberView: View {
    let storage: StorageService
    let member: TeamMember
    @State private var scores: [AssessmentCategory: Double] = [:]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                Text("Enter estimated scores for \(member.name) to see alignment gaps. These are for your planning purposes \u{2014} encourage team members to take the real assessment for accurate data.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Category Scores") {
                ForEach(AssessmentCategory.allCases, id: \.self) { category in
                    HStack {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundStyle(PulseTheme.categoryColor(for: category))
                            .frame(width: 20)
                        Text(category.rawValue)
                            .font(.subheadline)
                        Spacer()
                        TextField("0-100", value: Binding(
                            get: { scores[category] ?? 50 },
                            set: { scores[category] = min(100, max(0, $0)) }
                        ), format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    }
                }
            }
        }
        .navigationTitle("Simulate \(member.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveSimulatedScores()
                    dismiss()
                }
            }
        }
        .onAppear {
            for cat in AssessmentCategory.allCases {
                scores[cat] = 50
            }
        }
    }

    private func saveSimulatedScores() {
        let categoryScores = AssessmentCategory.allCases.map { cat in
            CategoryScore(
                category: cat,
                rawScore: Int(scores[cat] ?? 50),
                normalizedScore: scores[cat] ?? 50
            )
        }

        let totalWeighted = categoryScores.reduce(0.0) { $0 + $1.normalizedScore * $1.category.weight }
        let totalWeight = AssessmentCategory.allCases.reduce(0.0) { $0 + $1.weight }
        let overall = totalWeighted / totalWeight

        guard var data = storage.teamData,
              let idx = data.members.firstIndex(where: { $0.id == member.id }) else { return }

        data.members[idx].hasCompleted = true
        data.members[idx].categoryScores = categoryScores
        data.members[idx].overallScore = overall
        data.members[idx].completedDate = Date()
        storage.teamData = data
    }
}
