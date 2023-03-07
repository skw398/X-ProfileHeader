//
//  ContentView.swift
//  TwitterProfileHeader
//
//  Created by Shigenari Oshio on 2022/12/06.
//

import SwiftUI

struct ContentView: View {
    @State private var scrollAmount: CGFloat = .zero
    @State private var nameToHeaderDistance: CGFloat = .zero
    
    private let originHeaderHeight: CGFloat = 150
    private let shrinkHeaderScale: CGFloat = 0.3
    private var shrinkHeaderHeight: CGFloat { originHeaderHeight * shrinkHeaderScale }
    private var minHeaderHeight: CGFloat { originHeaderHeight - shrinkHeaderHeight }
    
    private let originalIconSize: CGFloat = 75
    private let overlappingHeaderIconScale: CGFloat = 0.3
    private var overlappingHeaderIconSize: CGFloat { originalIconSize * overlappingHeaderIconScale }
    
    private let scrollAmountForProcessCompletionWhenScrolled: CGFloat = 30
    private let scrollAmountForProcessCompletionWhenPulled: CGFloat = 200
    
    var body: some View {
        ZStack(alignment: .top) {
            headerContent
                .zIndex(1)
                .clipped()
                .frame(height: minHeaderHeight)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerImage
                        .zIndex(scrollAmount > shrinkHeaderHeight ? 1 : 0)
                        .frame(
                            width: UIScreen.main.bounds.width,
                            height: scrollAmount > 0
                            ? originHeaderHeight
                            : originHeaderHeight - scrollAmount
                        )
                        .clipped()
                        .offset(
                            y: scrollAmount > 0
                            ? scrollAmount > shrinkHeaderHeight ? scrollAmount - shrinkHeaderHeight : 0
                            : scrollAmount
                        )
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollAmountPreferenceKey.self,
                                    value: geo.frame(in: .global).minY * -1
                                )
                            }
                        )
                    
                    // Body
                    VStack(alignment: .leading) {
                        HStack(alignment: .bottom) {
                            icon
                            Spacer()
                            followButton
                        }
                        
                        profile
                        
                        ForEach(0..<10) { _ in
                            Text("Content")
                                .foregroundColor(.gray)
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .offset(
                        y: scrollAmount > 0
                        ? -overlappingHeaderIconSize
                        : -overlappingHeaderIconSize + scrollAmount
                    )
                }
                .onPreferenceChange(ScrollAmountPreferenceKey.self) {
                    scrollAmount = $0
                    print("scrollAmount", scrollAmount)
                }
                .onPreferenceChange(NameToHeaderSizePreferenceKey.self) {
                    nameToHeaderDistance = $0
                    print("nameToHeaderSize", nameToHeaderDistance)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var headerContent: some View {
        let yOffset: CGFloat = {
            scrollAmountForProcessCompletionWhenScrolled
            - (-nameToHeaderDistance)
                .clamp(to: 0...scrollAmountForProcessCompletionWhenScrolled)
        }()
        
        let opacity: CGFloat = {
            (-nameToHeaderDistance)
                .normalize(from: 0...scrollAmountForProcessCompletionWhenScrolled,
                           to: 0...1)
        }()
        
        return VStack(alignment: .leading) {
            Spacer()
            
            HStack {
                Button(action: {}) {
                    Circle()
                        .fill(.black)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.black)
                        .opacity(0.7)
                        .overlay {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                        }
                }
                .padding(.trailing)
                
                VStack(alignment: .leading) {
                    Text("葛飾北斎")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Text("99,999 Tweets")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 5)
                .offset(y: yOffset)
                .opacity(opacity)
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var headerImage: some View {
        let maxBlurRadiusWhenScrolled: CGFloat = 10
        let maxBlurRadiusWhenPulled: CGFloat = 30
        
        let blurRadiusWhenScrolled: CGFloat = {
            (-nameToHeaderDistance)
                .normalize(from: 0...scrollAmountForProcessCompletionWhenScrolled,
                           to: 0...maxBlurRadiusWhenScrolled)
        }()
        let blurRadiusWhenPulled: CGFloat = {
            abs(scrollAmount)
                .normalize(from: 0...scrollAmountForProcessCompletionWhenPulled,
                           to: 0...maxBlurRadiusWhenPulled)
        }()
        
        let blackTransparentBackgroundOpacity: CGFloat = {
            (-nameToHeaderDistance)
                .normalize(from: 0...scrollAmountForProcessCompletionWhenScrolled,
                           to: 0...0.5)
        }()
        
        return Image("冨嶽三十六景神奈川沖浪裏")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(Color.black.opacity(blackTransparentBackgroundOpacity))
            .blur(radius: scrollAmount > 0 ? blurRadiusWhenScrolled : blurRadiusWhenPulled)
    }
    
    private var icon: some View {
        let lineWidth: CGFloat = 5
        let scale: CGFloat = 1
        - scrollAmount
            .normalize(from: 0...shrinkHeaderHeight,
                       to: 0...overlappingHeaderIconScale)
        
        return Image("Icon")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color("Background"), lineWidth: lineWidth))
            .scaleEffect(scale, anchor: UnitPoint(x: 0.5, y: 1))
            .frame(width: originalIconSize, height: originalIconSize)
    }
    
    private var followButton: some View {
        let buttonHeight: CGFloat = 35
        
        return Button(action: {}) {
            Text("Following")
                .font(.subheadline)
                .padding(25)
                .foregroundColor(.primary)
                .frame(height: buttonHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: buttonHeight / 2)
                        .stroke(.gray, lineWidth: 1)
                )
        }
    }
    
    private var profile: some View {
        VStack(alignment: .leading) {
            Text("葛飾北斎")
                .font(.title2.bold())
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: NameToHeaderSizePreferenceKey.self,
                            value: geo.frame(in: .global).maxY - minHeaderHeight
                        )
                    }
                )
            Text("@hokusai")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("I'm an ukiyo-e artist.")
                .font(.body)
        }
    }
}

struct ScrollAmountPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct NameToHeaderSizePreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

private extension Comparable where Self == CGFloat {
    func clamp(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(range.upperBound, self))
    }
    
    func normalize(
        from originRange: ClosedRange<Self>,
        to newRange: ClosedRange<Self>
    ) -> Self {
        let normalized = (newRange.upperBound - newRange.lowerBound)
        * ((self - originRange.lowerBound) / (originRange.upperBound - originRange.lowerBound))
        + newRange.lowerBound
        
        return normalized.clamp(to: newRange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
