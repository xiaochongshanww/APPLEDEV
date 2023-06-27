import SwiftUI
import AVKit
import UIKit

class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var players: [AVAudioPlayer] = []
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        players.removeAll { $0 == player }
    }
}

struct ContentView: View {
    @State private var scale: CGFloat = 1.0
    @State private var hitCount: Int = 0
    @State private var floatingScores: [FloatingScore] = []

    private let playerDelegate = PlayerDelegate()
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    Text("功德值: \(hitCount)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .padding(.top, 20)
                    Spacer()
                }

                VStack {
                    Spacer()

                    Image("muyu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(scale)

                    Spacer()
                }

                ForEach(floatingScores, id: \.id) { score in
                    FloatingScoreText(geometry: geometry)
                        .onDisappear {
                            floatingScores.removeAll { $0.id == score.id }
                        }
                }
            }
            .onTapGesture {
                self.hapticFeedback.impactOccurred()

                let soundURL = Bundle.main.url(forResource: "hit", withExtension: "wav")!
                let currentPlayer = try! AVAudioPlayer(contentsOf: soundURL)
                currentPlayer.delegate = playerDelegate
                currentPlayer.play()
                playerDelegate.players.append(currentPlayer)
                self.hitCount += 1

                withAnimation(.easeInOut(duration: 0.1)) {
                    self.scale = 0.9
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.scale = 1.0
                    }
                }
                self.floatingScores.append(FloatingScore(id: UUID()))
                if self.floatingScores.count > 2 {
                    self.floatingScores.remove(at: 0)
                }
            }
            .statusBar(hidden: false)
            .statusBar(hidden: false)
            .preferredColorScheme(.light)
        }
    }

    struct FloatingScore: Identifiable {
        let id: UUID
    }
}


struct FloatingScoreText: View {
    let geometry: GeometryProxy
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        let position = min(geometry.size.width, geometry.size.height)
        
        Text("功德+1")
            .foregroundColor(.white)
            .font(.title)
            .position(x: geometry.size.width * 0.75, y: position / 2 + offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.25)) {
                    offset -= 30
                    opacity = 0
                }
            }
    }
}


struct Previews_ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ContentView() // Return your custom ContentView here
        }
}
