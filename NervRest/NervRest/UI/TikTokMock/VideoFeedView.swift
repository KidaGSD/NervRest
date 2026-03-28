import SwiftUI
import AVKit

// MARK: - Simple looping video player

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        let view = PlayerUIView(videoName: videoName)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

class PlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var player: AVPlayer?

    init(videoName: String) {
        self.initialVideoName = videoName
        super.init(frame: .zero)
        backgroundColor = .black

        guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else { return }
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        player?.isMuted = true

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        // Loop
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    @objc private func playerDidFinish() {
        // Switch to next video in the playlist
        currentIndex = (currentIndex + 1) % videoNames.count
        let nextName = videoNames[currentIndex]
        if let path = Bundle.main.path(forResource: nextName, ofType: "mp4") {
            let item = AVPlayerItem(url: URL(fileURLWithPath: path))
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            player?.replaceCurrentItem(with: item)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: item)
            player?.play()
        } else {
            player?.seek(to: .zero)
            player?.play()
        }
    }

    private var videoNames: [String] { [initialVideoName, "video-1", "video-2"].filter { Bundle.main.path(forResource: $0, ofType: "mp4") != nil } }
    private var currentIndex = 0
    private let initialVideoName: String

    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.pause()
    }
}

// MARK: - Wrapper with TikTok overlays

struct VideoCarouselWrapper: View {
    var body: some View {
        ZStack {
            // Looping video player — cycles through available videos
            LoopingVideoPlayer(videoName: "video-1")
                .ignoresSafeArea()

            // TikTok-style UI overlays
            VStack {
                // Top bar
                HStack(spacing: 16) {
                    Spacer()
                    Text("Following")
                        .foregroundColor(.white.opacity(0.5))
                    Text("For You")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Text("Live")
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .font(.system(size: 16))
                .padding(.top, 55)

                Spacer()

                HStack(alignment: .bottom) {
                    // Bottom-left caption
                    captionOverlay
                        .padding(.leading, 16)
                        .padding(.bottom, 24)

                    Spacer()

                    // Right sidebar
                    socialSidebar
                        .padding(.trailing, 12)
                        .padding(.bottom, 24)
                }
            }
        }
    }

    private var socialSidebar: some View {
        VStack(spacing: 22) {
            Image("image-profile-1")
                .renderingMode(.original)
                .resizable()
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

            sidebarItem(icon: "suit.heart.fill", label: "22.4k")
            sidebarItem(icon: "message.fill", label: "1,021")
            sidebarItem(icon: "arrowshape.turn.up.right.fill", label: "Share")
            sidebarItem(icon: "bookmark.fill", label: "Save")
        }
    }

    private func sidebarItem(icon: String, label: String) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 26))
            Text(label)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(.white)
    }

    private var captionOverlay: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 6) {
                Text("@creator")
                    .fontWeight(.bold)
                Text("· Follow")
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
            .font(.system(size: 14))

            Text("Late night scrolling vibes #fyp #nightowl")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)

            HStack(spacing: 5) {
                Image(systemName: "music.note")
                    .font(.system(size: 11))
                Text("Original Sound")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white.opacity(0.8))
        }
        .foregroundColor(.white)
        .padding(.trailing, 70)
    }
}

#Preview {
    VideoCarouselWrapper()
        .preferredColorScheme(.dark)
}
