import SwiftUI
import UIKit
import UniformTypeIdentifiers

private enum DopePatchPicker {
    static let types: [UTType] = [UTType(filenameExtension: "3105") ?? .data, .data]
}

struct DopeStyleView: View {
    @EnvironmentObject private var patchStore: PatchProjectStore
    @State private var selectedTab = 0
    @State private var showPatchImporter = false
    @State private var showBannerPicker = false
    @State private var bannerIndex = 0
    @State private var demoToggles: [Bool] = [false, false, false, false]

    private let tabs = ["Funções", "Partidas", "Configurações"]
    private let banners = ["Red Cry", "White Tree", "Night City", "Purple Sky"]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.04, green: 0.04, blue: 0.07), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        bannerCard
                        tabContent
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
                tabBar
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPatchImporter) {
            FileDocumentPicker(
                allowedContentTypes: DopePatchPicker.types,
                copiesSelectedDocument: true,
                allowsMultipleSelection: false,
                onSelection: { result in
                    showPatchImporter = false
                    if case .success(let urls) = result, let url = urls.first {
                        patchStore.importPackage(at: url)
                    }
                },
                onCancel: { showPatchImporter = false }
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showBannerPicker) {
            NavigationStack {
                List {
                    ForEach(Array(banners.enumerated()), id: \.offset) { index, name in
                        Button {
                            bannerIndex = index
                            showBannerPicker = false
                        } label: {
                            HStack {
                                Image(systemName: index == bannerIndex ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(.purple)
                                Text("Gif \(index + 1) - \(name).GIF")
                            }
                        }
                    }
                }
                .navigationTitle("Escolher banner")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.purple.opacity(0.25))
                Image(systemName: "bolt.fill").foregroundStyle(.purple, .white)
            }
            .frame(width: 42, height: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text("dope").font(.title2.bold())
                Text("Rkn Edition · modo seguro").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button { showBannerPicker = true } label: {
                Image(systemName: "photo.on.rectangle").font(.title3)
            }
            Button { } label: {
                Image(systemName: "moon.fill").font(.title3)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 14)
    }

    private var bannerCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.75), .blue.opacity(0.35), .black.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 132)
            VStack(alignment: .leading, spacing: 6) {
                Text("PAINEL RKN").font(.caption.bold()).tracking(2).foregroundStyle(.white.opacity(0.7))
                Text(banners[bannerIndex]).font(.title.bold())
                Text("Interface demonstrativa baseada no vídeo").font(.caption).foregroundStyle(.white.opacity(0.75))
            }
            .padding(18)
        }
    }

    @ViewBuilder private var tabContent: some View {
        switch selectedTab {
        case 0: functionsPanel
        case 1: matchesPanel
        default: settingsPanel
        }
    }

    private var functionsPanel: some View {
        VStack(spacing: 12) {
            sectionTitle("FUNÇÕES", subtitle: "Controles demonstrativos")
            demoSwitch(title: "Realce visual", subtitle: "Demonstração de interface", index: 0)
            demoSwitch(title: "Modo silencioso", subtitle: "Preferência visual local", index: 1)
            demoSwitch(title: "Indicador de desempenho", subtitle: "Exibe dados simulados", index: 2)
            demoSwitch(title: "Antena demonstrativa", subtitle: "Somente animação de UI", index: 3)
            safeNotice
        }
    }

    private var matchesPanel: some View {
        VStack(spacing: 12) {
            sectionTitle("PARTIDAS", subtitle: "Gerencie seus pacotes .3105")
            actionCard(
                title: "Adicionar patch 3105",
                subtitle: "Importe um pacote para aplicativos e dados que pertencem a você.",
                icon: "shippingbox.fill",
                action: { showPatchImporter = true }
            )
            if patchStore.items.isEmpty {
                Text("Nenhum patch adicionado")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 22)
            } else {
                ForEach(patchStore.items) { item in
                    HStack {
                        Image(systemName: "shippingbox.fill").foregroundStyle(.purple)
                        VStack(alignment: .leading) {
                            Text(item.project?.name ?? item.packageURL.lastPathComponent).font(.subheadline.weight(.semibold))
                            Text(item.packageURL.lastPathComponent).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            safeNotice
        }
    }

    private var settingsPanel: some View {
        VStack(spacing: 12) {
            sectionTitle("CONFIGURAÇÕES", subtitle: "Informações do aplicativo e dispositivo")
            infoCard(title: "Status da conta", value: "Ativo", icon: "checkmark.seal.fill", color: .green)
            infoCard(title: "Mantenedor", value: "Rkn · @RknDev1", icon: "person.fill", color: .purple)
            infoCard(title: "Versão do iOS", value: UIDevice.current.systemVersion, icon: "iphone", color: .blue)
            infoCard(title: "Compatibilidade", value: "Build 24A446 · experimental", icon: "checkmark.circle.fill", color: .orange)
            Text("Esta versão não inclui login. Os controles de Funções são demonstrativos e não modificam jogos ou memória do dispositivo.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                Button { withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index } } label: {
                    VStack(spacing: 5) {
                        Image(systemName: ["slider.horizontal.3", "gamecontroller.fill", "gearshape.fill"][index])
                        Text(title).font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(selectedTab == index ? .purple : .secondary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.ultraThinMaterial)
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.caption.bold()).tracking(1.5).foregroundStyle(.purple)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func demoSwitch(title: String, subtitle: String, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.body.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { demoToggles[index] },
                set: { demoToggles[index] = $0 }
            ))
            .labelsHidden()
            .tint(.purple)
        }
        .padding(16)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
    }

    private func actionCard(title: String, subtitle: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon).font(.title3).foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(.purple, in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.body.weight(.semibold)).foregroundStyle(.primary)
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary)
            }
            .padding(14)
            .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func infoCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon).foregroundStyle(color).frame(width: 26)
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
        .padding(15)
        .background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 15))
    }

    private var safeNotice: some View {
        Label("Modo seguro: sem injeção ou alteração de memória", systemImage: "lock.shield.fill")
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}
