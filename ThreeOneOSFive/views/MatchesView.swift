import SwiftUI
import UniformTypeIdentifiers

private enum MatchPatchPickerPolicy {
    static let packageType = UTType(filenameExtension: "3105") ?? .data
    static let allowedContentTypes: [UTType] = [packageType, .data]
}

/// A safe, non-cheat workspace for organizing .3105 patches used with apps and data the user owns.
struct MatchesView: View {
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var store: PatchProjectStore
    @State private var showPatchImporter = false
    let onOpenSettings: () -> Void
    let onOpenLogs: () -> Void

    init(
        onOpenSettings: @escaping () -> Void = {},
        onOpenLogs: @escaping () -> Void = {}
    ) {
        self.onOpenSettings = onOpenSettings
        self.onOpenLogs = onOpenLogs
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showPatchImporter = true
                    } label: {
                        Label(
                            language.text("matches.add_patch"),
                            systemImage: "doc.badge.plus"
                        )
                    }
                    .disabled(store.isBusy)
                } footer: {
                    Text(language.text("matches.footer"))
                }

                Section(language.text("matches.imported")) {
                    if store.items.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "shippingbox")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                            Text(language.text("matches.empty_title"))
                                .font(.headline)
                            Text(language.text("matches.empty_message"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                    } else {
                        ForEach(store.items) { item in
                            HStack(spacing: 12) {
                                Image(systemName: "shippingbox.fill")
                                    .foregroundStyle(AppTheme.accent)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.project?.name ?? item.packageURL.deletingPathExtension().lastPathComponent)
                                        .font(.body.weight(.semibold))
                                    Text(item.packageURL.lastPathComponent)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
            }
            .navigationTitle(language.text("tab.matches"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                AppUtilityToolbar(
                    language: language,
                    onOpenSettings: onOpenSettings,
                    onOpenLogs: onOpenLogs
                )
            }
            .overlay {
                if store.isBusy {
                    ProgressView()
                        .padding(18)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .sheet(isPresented: $showPatchImporter) {
                FileDocumentPicker(
                    allowedContentTypes: MatchPatchPickerPolicy.allowedContentTypes,
                    copiesSelectedDocument: true,
                    allowsMultipleSelection: false,
                    onSelection: { result in
                        showPatchImporter = false
                        if case .success(let urls) = result, let url = urls.first {
                            store.importPackage(at: url)
                        }
                    },
                    onCancel: {
                        showPatchImporter = false
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
}
