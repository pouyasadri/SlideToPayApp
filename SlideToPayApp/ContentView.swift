//
//  ContentView.swift
//  SlideToPayApp
//
//  Created by Pouya Sadri on 05/02/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		ZStack{
			Color.black
				.ignoresSafeArea()
			
			KeypadSwipeView()
		}
    }
}

#Preview {
    ContentView()
}
//MARK: - Keypad swipe view
struct KeypadSwipeView : View {
	
	@State private var isUnlcoked = false
	@State private var enteredText : String = ""
	
	var body: some View {
		VStack{
			if isUnlcoked {
				AnimationView(valueOfMoney: $enteredText)
			}else {
				AmountEntryView(entredText: $enteredText)
				KeypadView(enteredText: $enteredText)
				SwipeView(isUnlocked: $isUnlcoked)
			}
		}
	}
}


//MARK: - Amount entry view
struct AmountEntryView : View {
	@Binding var entredText : String
	var body: some View {
		VStack{
			HStack{
				Text("Enter Amount")
					.font(.system(size: 20))
					.background(.black)
					.foregroundStyle(.white)
				Spacer()
			}
			TextField("000000",text: $entredText)
				.font(.system(size: 45))
				.background(.black)
				.foregroundStyle(.white)
		}
		.padding(10)
	}
}

//MARK: - Key pad buttons
struct KeypadButtonsView : View {
	let key : String
	@Binding var enteredText : String
	
	var body: some View {
		Button(action: {
			handleKeypadButton(key: key)
		}, label: {
			ZStack{
				Circle()
					.frame(width: 100,height: 100)
					.background(.black)
					.foregroundStyle(.white)
					.opacity(0.08)
				
				Text(key)
					.font(.system(size: 45))
					.fontWeight(.regular)
					.foregroundStyle(.white)
					.cornerRadius(100)
			}
		})
	}
	
	func handleKeypadButton(key: String){
		if key.isEmpty {
			enteredText = String(enteredText.dropLast())
		}else {
			enteredText += key
		}
	}
}


//MARK: - Key pad view
struct KeypadView : View {
	@Binding var enteredText : String
	
	let keypad: [[String]] = [
		["1","2","3"],
		["4","5","6"],
		["7","8","9"],
		["*","0","#"]
	]
	var body: some View {
		VStack(spacing:20){
			ForEach(keypad, id :\.self){row in
				HStack(spacing:20){
					ForEach(row,id: \.self){ key in
						KeypadButtonsView(key: key, enteredText: $enteredText)
					}
				}
				
			}
		}
	}
}
//MARK: - Swipe View
struct SwipeView : View {
	@State private var sliderOffset : CGFloat = 0
	@Binding var isUnlocked : Bool
	var body: some View {
		ZStack{
			Text(isUnlocked ? "Sending..." : "> > >")
				.font(.title2)
				.foregroundStyle(.white)
				.opacity(0.5)
				.padding()
			ZStack(alignment: isUnlocked ? .trailing : .leading){
				RoundedRectangle(cornerRadius: 60)
					.frame(width: 340,height: 75)
					.foregroundStyle(.gray.opacity(0.1))
				
				Image(systemName: "dollarsign.circle")
					.resizable()
					.frame(width: 60,height: 60)
					.foregroundStyle(.white)
					.offset(x: sliderOffset)
					.gesture(
						DragGesture()
							.onChanged{
								value in
								sliderOffset = max(min(value.translation.width,280),10)
							}
							.onEnded{
								value in
								if sliderOffset > 200 {
									isUnlocked = true
								}
								else{
									withAnimation(){
										sliderOffset = 0
									}
								}
							}
					
					)
			}
		}
	}
}
//MARK: - Animation View
struct AnimationView : View {
	@State private var dollarOffset = false
	@State private var dollarOpacity = false
	@State private var showLoader = false
	@Binding var valueOfMoney : String
	var body: some View {
		ZStack{
			Image(systemName: "dollarsign.circle")
				.resizable()
				.foregroundStyle(.green)
				.frame(width: dollarOffset ? 300 : 60,height: dollarOffset ? 300 : 60)
				.offset(x: dollarOffset ? 0 : 130, y: dollarOffset ? 200 : 650)
				.animation(.easeInOut, value: 0)
				.onAppear{
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
						withAnimation{
							dollarOffset.toggle()
						}
					}
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
						withAnimation{
							dollarOffset.toggle()
						}
					}
					
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
						withAnimation{
							showLoader.toggle()
						}
					}
				}
			
			ZStack{
				HStack{
					Text(valueOfMoney)
						.font(.system(size: 72))
						.fontWeight(.regular)
						.foregroundStyle(.white)
					
					Text("$")
						.font(.system(size: 30))
						.fontWeight(.regular)
						.foregroundStyle(.white)
						.offset(y:12)
				}
				if showLoader{
					CircularLoaderView()
				}
			}
			
		}
	}
}
//MARK: - CircularLoaderView
struct CircularLoaderView : View {
	@State private var border : CGFloat = 0.0
	@State private var isLoading : Bool = true
	@State private var showTick = false
	
	let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	var body: some View {
		ZStack{
			
			Circle()
				.stroke(lineWidth: 10)
				.opacity(0.3)
				.foregroundStyle(.green)
			
			Circle()
				.trim(from: 0.0,to: border)
				.stroke(style: StrokeStyle(lineWidth: 10,lineCap: .round,lineJoin: .round))
				.foregroundStyle(.green)
				.rotationEffect(Angle(degrees: 360))
				.onAppear(){
					DispatchQueue.main.asyncAfter(deadline: .now() + 5){
						withAnimation(){
							showTick.toggle()
						}
					}
				}
				.onReceive(timer, perform: { _ in
					withAnimation{
						border += 0.02
						if border >= 1 {
							isLoading = false
							timer.upstream.connect().cancel()
						}
					}
				})
			
			if showTick {
				TickMarkShapeView()
					.trim(from: 0.0,to: 1)
					.stroke(.green,lineWidth: 4)
					.offset(x: -10)
				
				
			}
			if showTick{
				ShowSentView()
			}
			
			
		}
		.offset(x: 0 , y: 215)
		.frame(width: 150,height: 150)
		.padding()
	}
}
//MARK: - TickMarkShapeView
struct TickMarkShapeView : Shape{
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: rect.midX - 20, y: rect.midY))
		path.addLine(to: CGPoint(x: rect.midX, y: rect.midY + 20))
		path.addLine(to: CGPoint(x: rect.midX + 40, y: rect.midY - 20))
		return path
	}
}
//MARK: - Show Sent view
struct ShowSentView : View {
	@State private var showRectangle = false
	var body: some View {
		ZStack{
			if showRectangle{
				ZStack{
					RoundedRectangle(cornerRadius: 60)
						.frame(width: 340,height: 75)
						.foregroundStyle(.black)
					
					RoundedRectangle(cornerRadius: 60)
						.frame(width: 340,height: 75)
						.foregroundStyle(.white)
					
					Text("S E N T")
						.font(.title2)
						.foregroundStyle(.black)
				}
			}
		}
		.offset(y: 325)
		.onAppear{
			DispatchQueue.main.asyncAfter(deadline: .now()){
				showRectangle = true
			}
		}
	}
}
