//
//  ContentView.swift
//  wordgarden
//
//  Created by Rajveer Mann on 25/09/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var wordsguessed = 0
    @State private var wordsmissed = 0
    @State private var currentword = 0
    @State private var gamemessage = "how many guesses to uncover the hidden word?"
    @State private var guessedletter = ""
    @State private var wordtoguess = ""
    @State private var revealedword = ""
    @State private var image = "flower8"
    @State private var guessesremaining = 8
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var secondbutton = true
    @State private var audioplayer : AVAudioPlayer!
    @State private var lettersguessed = ""
    @FocusState private var focused : Bool
    private let wordstoguess = ["SWIFT","DOG","CAT"]
    private let maximumguesses = 8
    
    var body: some View {
        VStack {
            HStack{
                VStack(alignment: .trailing){
                    Text("words guessed :  \(wordsguessed)")
                    Text("words missed :  \(wordsmissed)")
                }
                
                Spacer()
                VStack(alignment: .leading){
                    Text("words to guess:  \(wordstoguess.count-(wordsguessed + wordsmissed))")
                    Text("words in game :  \(wordstoguess.count)")
                }
            }
            .padding(.horizontal)
            Text(gamemessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
            
            Text(revealedword)
                .font(.title)
                .padding(.top)
            if secondbutton{
                HStack{
                    TextField(" ", text: $guessedletter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedletter) {
                            guessedletter = guessedletter.trimmingCharacters(in: .letters.inverted)
                            
                            guard let lastchar = guessedletter.last
                            else {
                                return
                            }
                            guessedletter = String(lastchar).uppercased()
                            
                        }
                        .onSubmit {
                            guard guessedletter != " " else {
                                return
                            }
                            guessaletter()
                            updategameplay()
                        }
                        .focused($focused)
                    
                    
                    Button("guess a letter"){
                        guessaletter()
                        updategameplay()
                    }
                    .buttonStyle(.bordered)
                    .disabled(guessedletter.isEmpty)
                    .tint(.mint)
                }
            }else{
                Button(playAgainButtonLabel){
                    if currentword == wordstoguess.count {
                        currentword = 0
                        wordsguessed = 0
                        wordsmissed = 0
                    }
                    playAgainButtonLabel = "Another Word?"
                    wordtoguess = wordstoguess[currentword]
                    revealedword = " _ " + String (repeating: " _ ", count: wordtoguess.count-1)
                    guessesremaining = maximumguesses
                    lettersguessed = ""
                    image = "flower\(guessesremaining)"
                    gamemessage = "how many guesses to uncover the hidden word"
                    secondbutton = true
                }
                .buttonStyle(.borderedProminent)
            }
            Spacer()
            Image(image)
                .resizable()
                .scaledToFit()
//                .frame(width: 300, height: 530)
                .animation(.easeIn(duration: 0.75),value: image)
        }
    
        .ignoresSafeArea(edges : .bottom)
        .onAppear(){
            wordtoguess = wordstoguess[currentword]
            revealedword = " _ " + String (repeating: " _ ", count: wordtoguess.count-1)
            guessesremaining = maximumguesses
        }
    }
    func guessaletter (){
        focused = false
        lettersguessed = lettersguessed + guessedletter
        revealedword = ""
        
        for letter in wordtoguess {
            
            if lettersguessed.contains (letter) {
                revealedword = revealedword + "\(letter) "
            } else {
                
                revealedword = revealedword + " _ "
            }
        }
        revealedword.removeLast ()
    }
    func updategameplay (){
        gamemessage = "you have made \(lettersguessed.count) guess\(guessedletter.count == 1 ? "" : "es")"
        if !wordtoguess.contains(guessedletter){
            guessesremaining -= 1
            image = "wilt\(guessesremaining)"
            playSound(soundName: "incorrect")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                image = "flower\(guessesremaining)"
                
            }
        }else{
            playSound(soundName: "correct")
        }
        if !revealedword.contains("_") {
            
            gamemessage = "You've Guessed It! It Took You\(lettersguessed.count) Guesses to Guess the Word."
            wordsguessed += 1
            currentword += 1
            secondbutton = false
            playSound(soundName: "word-guessed")
        } else if guessesremaining == 0 {
            gamemessage = "So Sorry. You're All Out of Guesses."
            wordsmissed += 1
            currentword += 1
            secondbutton = false
            playSound(soundName: "word-not-guessed")
        } else { // Keep guessing
            gamemessage = "You've Made \(lettersguessed.count)Guess\(lettersguessed.count == 1 ? "" : "es")"
        }
        
        if currentword == wordstoguess.count {
            playAgainButtonLabel = "restart game?"
            gamemessage = gamemessage + "\nYou've Tried all the words . restart from the beginning "
        }
        guessedletter = ""
        
        func playSound (soundName: String) {
            guard let soundFile = NSDataAsset (name: soundName) else {
                print("@Could not read file named \(soundName)")
                return
            }
            do {
                audioplayer = try AVAudioPlayer(data: soundFile.data)
                audioplayer.play()
            } catch {
                print("@ERROR: \(error.localizedDescription) creating audioPlayer.")
            }
        }
    }
}
#Preview {
    ContentView()
}
