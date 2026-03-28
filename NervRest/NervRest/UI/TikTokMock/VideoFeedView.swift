import SwiftUI
import AVKit

// MARK: - Data Model

struct MockVideo: Identifiable {
    let id: Int
    let player: AVPlayer
    let resourceName: String
}

// MARK: - Video Carousel (UIScrollView-based vertical paging)

struct VideoCarouselView: UIViewRepresentable {
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: VideoCarouselView
        var currentIndex = 0

        init(_ parent: VideoCarouselView) {
            self.parent = parent
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let newIndex = Int(scrollView.contentOffset.y / scrollView.frame.height)
            guard newIndex != currentIndex, newIndex >= 0, newIndex < parent.videos.count else { return }

            // Pause old, play new
            parent.videos[currentIndex].player.pause()
            currentIndex = newIndex
            let current = parent.videos[currentIndex]
            current.player.seek(to: .zero)
            current.player.play()
        }
    }

    let videos: [MockVideo]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = context.coordinator
        scrollView.backgroundColor = .black

        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        scrollView.contentSize = CGSize(
            width: screenWidth,
            height: screenHeight * CGFloat(videos.count)
        )

        for (index, video) in videos.enumerated() {
            let playerVC = AVPlayerViewController()
            playerVC.player = video.player
            playerVC.showsPlaybackControls = false
            playerVC.videoGravity = .resizeAspectFill
            playerVC.view.backgroundColor = .black
            playerVC.view.frame = CGRect(
                x: 0,
                y: screenHeight * CGFloat(index),
                width: screenWidth,
                height: screenHeight
            )
            scrollView.addSubview(playerVC.view)
        }

        // Play first video
        if let first = videos.first {
            first.player.play()
            loopVideo(first.player)
        }

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}

    private func loopVideo(_ player: AVPlayer) {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }
    }
}

// MARK: - Wrapper with overlays

struct VideoCarouselWrapper: View {
    @State private var videos: [MockVideo] = []

    private static let videoNames = ["video-1", "video-5", "video-8", "video-9"]

    var body: some View {
        ZStack {
            if videos.isEmpty {
                Color.black
                    .ignoresSafeArea()
                    .onAppear { loadVideos() }
            } else {
                VideoCarouselView(videos: videos)
                    .ignoresSafeArea()

                // TikTok-style UI overlays
                VStack {
                    Spacer()
                    HStack(alignment: .bottom) {
                        // Bottom-left caption
                        captionOverlay
                            .padding(.leading, 16)
                            .padding(.bottom, 16)

                        Spacer()

                        // Right sidebar
                        socialSidebar
                            .padding(.trailing, 12)
                            .padding(.bottom, 80)
                    }
                }
            }
        }
    }

    // MARK: - Social Sidebar

    private var socialSidebar: some View {
        VStack(spacing: 20) {
            Button(action: {}) {
                Image("image-profile-1")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }

            sidebarButton(icon: "suit.heart.fill", label: "22.4k")
            sidebarButton(icon: "message.fill", label: "1,021")
            sidebarButton(icon: "arrowshape.turn.up.right.fill", label: "Share")
            sidebarButton(icon: "bookmark.fill", label: "Save")
        }
    }

    private func sidebarButton(icon: String, label: String) -> some View {
        Button(action: {}) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Caption

    private var captionOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("@creator_name")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text("· Follow")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }
            Text("Late night scrolling vibes #fyp #relatable")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.system(size: 11))
                Text("Original Sound - creator_name")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white.opacity(0.85))
        }
        .padding(.trailing, 60)
    }

    // MARK: - Load

    private func loadVideos() {
        videos = Self.videoNames.enumerated().compactMap { index, name in
            guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else { return nil }
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            player.isMuted = true
            return MockVideo(id: index, player: player, resourceName: name)
        }
    }
}

#Preview {
    VideoCarouselWrapper()
        .preferredColorScheme(.dark)
}
