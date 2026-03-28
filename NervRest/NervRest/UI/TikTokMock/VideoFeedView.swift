//
//  VideoFeedView.swift
//  NervRest
//
//  Adapted from ShortVideoApp (open-source TikTok clone).
//  Simplified: no bottom tab bar, no top navigation pills.
//  Uses TabView for modern SwiftUI vertical paging.
//

import SwiftUI
import AVKit

// MARK: - Data Model

struct MockVideo: Identifiable {
    let id: Int
    let player: AVPlayer
    let resourceName: String
    var replay: Bool = false
}

// MARK: - Video Carousel (vertical paging)

struct VideoCarouselView: View {
    @State private var videos: [MockVideo] = []
    @State private var currentIndex: Int = 0

    /// Only 4 videos to keep bundle size small.
    private static let videoNames = ["video-1", "video-5", "video-8", "video-9"]

    var body: some View {
        GeometryReader { geo in
            if videos.isEmpty {
                Color.black
                    .onAppear { loadVideos() }
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(videos) { video in
                        ZStack {
                            VideoPlayerRepresentable(player: video.player)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()

                            // Right-side social buttons overlay
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    socialSidebar
                                        .padding(.trailing, 12)
                                        .padding(.bottom, geo.safeAreaInsets.bottom + 80)
                                }
                            }

                            // Bottom caption overlay
                            VStack {
                                Spacer()
                                captionOverlay
                                    .padding(.leading, 16)
                                    .padding(.trailing, 80)
                                    .padding(.bottom, geo.safeAreaInsets.bottom + 16)
                            }
                        }
                        .tag(video.id)
                        .ignoresSafeArea()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))
                .rotationEffect(.degrees(-90))
                .frame(width: geo.size.height, height: geo.size.width)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                .ignoresSafeArea()
                .onChange(of: currentIndex) { _, newIndex in
                    handlePageChange(to: newIndex)
                }
            }
        }
        .background(Color.black)
        .ignoresSafeArea()
    }

    // MARK: - Social Sidebar

    private var socialSidebar: some View {
        VStack(spacing: 20) {
            // Profile image
            Button(action: {}) {
                Image("image-profile-1")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: 1.5)
                    )
            }

            // Like
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "suit.heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    Text("22.4k")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Comment
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                    Text("1,021")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Share
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                    Text("Share")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            // Bookmark
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Save")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Caption Overlay

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

            Text("Late night scrolling vibes #fyp #relatable #nightowl")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)

            HStack(spacing: 6) {
                Image(systemName: "music.note")
                    .font(.system(size: 11))
                    .foregroundColor(.white)
                Text("Original Sound - creator_name")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
        }
    }

    // MARK: - Playback Control

    private func loadVideos() {
        videos = Self.videoNames.enumerated().compactMap { index, name in
            guard let path = Bundle.main.path(forResource: name, ofType: "mp4") else {
                return nil
            }
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            player.isMuted = true // mute for demo
            return MockVideo(id: index, player: player, resourceName: name)
        }
        // Auto-play first video
        if let first = videos.first {
            first.player.play()
            loopVideo(first.player)
        }
    }

    private func handlePageChange(to newIndex: Int) {
        for video in videos {
            video.player.pause()
            video.player.seek(to: .zero)
        }
        guard newIndex >= 0, newIndex < videos.count else { return }
        let current = videos[newIndex]
        current.player.seek(to: .zero)
        current.player.play()
        loopVideo(current.player)
    }

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

// MARK: - AVPlayer UIViewControllerRepresentable

struct VideoPlayerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        controller.view.backgroundColor = .black
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Player instance doesn't change — nothing to update.
    }
}

// MARK: - Wrapper (public API)

struct VideoCarouselWrapper: View {
    var body: some View {
        VideoCarouselView()
    }
}

// MARK: - Preview

#Preview {
    VideoCarouselWrapper()
        .preferredColorScheme(.dark)
}
