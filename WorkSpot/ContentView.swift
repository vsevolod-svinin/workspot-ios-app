//
//  ContentView.swift
//  WorkSpot
//
//  Created by sebastian.projects on 11.10.2026.
//

import SwiftUI

private enum WorkSpotStyle {
    static let green = Color(red: 0.31, green: 0.61, blue: 0.19)
    static let lightGreen = Color(red: 0.78, green: 0.88, blue: 0.67)
    static let darkGreen = Color(red: 0.27, green: 0.39, blue: 0.32)
    static let paleGreen = Color(red: 0.91, green: 0.95, blue: 0.87)
    static let gold = Color(red: 1.0, green: 0.68, blue: 0.02)
    static let gray = Color(red: 0.84, green: 0.85, blue: 0.83)
    static let ink = Color(red: 0.08, green: 0.10, blue: 0.09)
}

private enum MainTab {
    case map, favorites, profile
}

private struct Review: Identifiable {
    let id = UUID()
    let name: String
    let date: String
    let rating: Int
    let text: String
}

private struct Place {
    let name: String
    let type: String
    let price: String
    let rating: String
    let reviewCount: Int
    let openingHours: String
    let noise: Int
    let comfort: Int
    let wifi: Int
    let power: Int
    let description: String
}

struct ContentView: View {
    @State private var selectedTab: MainTab = .map
    @State private var showDetails = false
    @State private var showReviews = false
    @State private var showAddPlaceScreen = false
    @State private var showRatingScreen = false
    @State private var showFilters = false
    @State private var showMapPlaceCard = false
    @State private var isFavorite = false
    @State private var searchText = ""

    @State private var noiseRating = 0
    @State private var comfortRating = 0
    @State private var wifiRating = 0
    @State private var powerRating = 0
    @State private var reviewText = ""

    @State private var newPlaceName = ""
    @State private var newPlaceAddress = ""
    @State private var newPlaceType = "Café"
    @State private var newPlacePrice = "Free"
    @State private var newPlaceHours = ""
    @State private var newPlaceInfo = ""

    private let place = Place(
        name: "Röstbar",
        type: "Café",
        price: "€€",
        rating: "4.3",
        reviewCount: 128,
        openingHours: "08:00 – 22:00",
        noise: 4,
        comfort: 4,
        wifi: 5,
        power: 4,
        description: "Modern café with a relaxed atmosphere, great coffee and stable Wi-Fi."
    )

    private let reviews = [
        Review(name: "Anna", date: "12 Mar 2026", rating: 5, text: "Great place to work! Quiet and fast Wi-Fi."),
        Review(name: "Mark", date: "5 Mar 2026", rating: 4, text: "Nice atmosphere and comfortable chairs. A bit noisy in the afternoon."),
        Review(name: "Lisa", date: "28 Feb 2026", rating: 4, text: "Perfect for studying. Many power outlets and good coffee.")
    ]

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            Group {
                if showAddPlaceScreen {
                    addPlaceScreen
                } else if showRatingScreen {
                    ratePlaceScreen
                } else if showReviews {
                    reviewsScreen
                } else if showDetails {
                    detailsScreen
                } else {
                    switch selectedTab {
                    case .map: mapScreen
                    case .favorites: favoritesScreen
                    case .profile: profileScreen
                    }
                }
            }

            bottomBar
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .preferredColorScheme(.light)
        .sheet(isPresented: $showFilters) {
            FilterSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: Map

    private var mapScreen: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 9) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 19, weight: .medium))
                    TextField("Search for cafés, coworking...", text: $searchText)
                        .font(.system(size: 15))
                        .submitLabel(.search)
                }
                .padding(.horizontal, 13)
                .frame(height: 48)
                .background(WorkSpotStyle.paleGreen)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(WorkSpotStyle.green, lineWidth: 1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button { showFilters = true } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(.black)
                        .frame(width: 38, height: 44)
                }
                .accessibilityLabel("Filters")
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)

            ZStack(alignment: .bottom) {
                MapArtwork()
                    .ignoresSafeArea(edges: .bottom)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showMapPlaceCard = false
                    }

                // Only the Röstbar marker is interactive: it reveals the preview card.
                Button {
                    showMapPlaceCard = true
                } label: {
                    MapPin(symbol: "cup.and.saucer.fill", color: WorkSpotStyle.green)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Show Röstbar preview")
                .position(x: 92, y: 145)

                // Decorative map markers; they do not open any place.
                MapPin(symbol: "laptopcomputer", color: WorkSpotStyle.darkGreen)
                    .allowsHitTesting(false)
                    .position(x: 208, y: 192)

                MapPin(symbol: "book.closed.fill", color: WorkSpotStyle.green)
                    .allowsHitTesting(false)
                    .position(x: 70, y: 285)

                MapPin(symbol: "cup.and.saucer.fill", color: WorkSpotStyle.darkGreen)
                    .allowsHitTesting(false)
                    .position(x: 225, y: 355)

                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button {} label: {
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(WorkSpotStyle.ink)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(WorkSpotStyle.gray, lineWidth: 1))
                        }
                        .accessibilityLabel("My location")
                    }

                    if showMapPlaceCard {
                        Button { openPlace() } label: {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 8)
                                .fill(WorkSpotStyle.paleGreen)
                                .frame(width: 52, height: 52)
                                .overlay {
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 23))
                                        .foregroundStyle(WorkSpotStyle.green)
                                }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Röstbar")
                                    .font(.system(size: 19, weight: .semibold))
                                Text("4.3  ·  €€  ·  Open now")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(.white)

                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                            .padding(12)
                            .background(WorkSpotStyle.green)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(WorkSpotStyle.darkGreen, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 94)
            }
            .overlay(alignment: .trailing) {
                VStack {
                    Spacer()
                    Button { openAddPlace() } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 23, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(WorkSpotStyle.green)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                    }
                    .accessibilityLabel("Add a place")
                    .padding(.trailing, 22)
                    .padding(.bottom, 230)
                }
            }
        }
    }

    // MARK: Place Details

    private var detailsScreen: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    showDetails = false
                    showReviews = false
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                }
                Spacer()
                Button { isFavorite.toggle() } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 27, weight: .medium))
                        .foregroundStyle(isFavorite ? .pink : WorkSpotStyle.ink)
                }
                .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 10)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    CafePhotoPlaceholder()
                        .frame(height: 190)
                        .clipShape(RoundedRectangle(cornerRadius: 25))

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(place.name)
                                .font(.system(size: 25, weight: .semibold))
                            Text("\(place.type) · \(place.price)")
                                .font(.system(size: 19, weight: .medium))
                        }
                        .foregroundStyle(WorkSpotStyle.darkGreen)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 9) {
                            Text("Open now")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 13)
                                .padding(.vertical, 11)
                                .background(WorkSpotStyle.green)
                                .clipShape(RoundedRectangle(cornerRadius: 11))
                            Text(place.openingHours)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(WorkSpotStyle.darkGreen)
                        }
                    }

                    HStack(spacing: 7) {
                        Image(systemName: "star.fill").foregroundStyle(WorkSpotStyle.gold)
                        Text(place.rating).fontWeight(.semibold)
                        Text("(\(place.reviewCount) reviews)")
                    }
                    .font(.system(size: 18))
                    .foregroundStyle(WorkSpotStyle.darkGreen)

                    VStack(spacing: 12) {
                        RatingRow(icon: "speaker.wave.2.fill", title: "Noise level", rating: place.noise)
                        RatingRow(icon: "chair.lounge.fill", title: "Comfort", rating: place.comfort)
                        RatingRow(icon: "wifi", title: "Wi-Fi", rating: place.wifi)
                        RatingRow(icon: "powerplug.fill", title: "Power outlet", rating: place.power)
                    }
                    .padding(.top, 4)

                    Text(place.description)
                        .font(.system(size: 15))
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 3)

                    Button { showReviews = true } label: {
                        FormActionButton(title: "View reviews", filled: false)
                    }

                    Button { openRatePlace() } label: {
                        FormActionButton(title: "Rate this place", filled: false)
                    }
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: Rate a Place

    private var ratePlaceScreen: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Rate this place") {
                showRatingScreen = false
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    StarScaleRow(icon: "speaker.wave.2.fill", title: "Noise level", rating: $noiseRating)
                    StarScaleRow(icon: "chair.lounge.fill", title: "Comfort", rating: $comfortRating)
                    StarScaleRow(icon: "wifi", title: "Wi-Fi", rating: $wifiRating)
                    StarScaleRow(icon: "battery.100percent", title: "Power outlet", rating: $powerRating)

                    Text("Your review (optional)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                        .padding(.top, 8)

                    TextField("Write about your experience ...", text: $reviewText, axis: .vertical)
                        .font(.system(size: 15))
                        .foregroundStyle(WorkSpotStyle.green)
                        .multilineTextAlignment(.center)
                        .lineLimit(4...6)
                        .padding(12)
                        .frame(minHeight: 125, alignment: .top)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(WorkSpotStyle.green, lineWidth: 2))
                        .padding(.horizontal, 4)

                    Button {
                        showRatingScreen = false
                        showReviews = true
                        showDetails = false
                    } label: {
                        FormActionButton(title: "Submit", filled: false)
                    }
                    .padding(.bottom, 105)
                }
                .padding(.horizontal, 25)
            }
        }
    }

    // MARK: Add a Place

    private var addPlaceScreen: some View {
        VStack(spacing: 0) {
            PageHeader(title: "Add a place") {
                showAddPlaceScreen = false
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 11) {
                        AddFieldLabel(title: "Name")
                        TextField("Enter name", text: $newPlaceName).workSpotInput()

                        AddFieldLabel(title: "Address")
                        TextField("Enter address", text: $newPlaceAddress).workSpotInput()

                        AddFieldLabel(title: "Type")
                        Picker("Type", selection: $newPlaceType) {
                            Text("Café").tag("Café")
                            Text("Coworking").tag("Coworking")
                            Text("Library").tag("Library")
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 54)
                        .padding(.horizontal, 14)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(WorkSpotStyle.green, lineWidth: 2))

                        AddFieldLabel(title: "Price level")
                        HStack(spacing: 10) {
                            ForEach(["Free", "€", "€€", "€€€"], id: \.self) { level in
                                Button { newPlacePrice = level } label: {
                                    Text(level)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(newPlacePrice == level ? .white : WorkSpotStyle.green)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 44)
                                        .background(newPlacePrice == level ? WorkSpotStyle.green : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 9))
                                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(WorkSpotStyle.green, lineWidth: 2))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        AddFieldLabel(title: "Opening hours")
                        TextField("e.g. 8:00 – 22:00", text: $newPlaceHours).workSpotInput()
                    }

                    VStack(alignment: .leading, spacing: 11) {
                        AddFieldLabel(title: "Additional information (optional)")
                        TextField("Enter details...", text: $newPlaceInfo, axis: .vertical)
                            .lineLimit(3...4)
                            .padding(12)
                            .frame(minHeight: 82, alignment: .topLeading)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(WorkSpotStyle.green, lineWidth: 2))

                        Button {
                            showAddPlaceScreen = false
                            selectedTab = .map
                            clearAddPlaceForm()
                        } label: {
                            FormActionButton(title: "Submit", filled: false)
                        }
                        .padding(.top, 7)
                        .padding(.bottom, 105)
                    }
                }
                .font(.system(size: 17))
                .foregroundStyle(WorkSpotStyle.darkGreen)
                .padding(.horizontal, 25)
            }
        }
    }

    private func clearAddPlaceForm() {
        newPlaceName = ""
        newPlaceAddress = ""
        newPlaceType = "Café"
        newPlacePrice = "Free"
        newPlaceHours = ""
        newPlaceInfo = ""
    }

    // MARK: Reviews

    private var reviewsScreen: some View {
        VStack(spacing: 0) {
            HStack {
                Button { showReviews = false } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                }
                Spacer()
                Text("Reviews")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
                Spacer()
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(WorkSpotStyle.ink)
            }
            .padding(.horizontal, 24)
            .padding(.top, 15)
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 9) {
                        Image(systemName: "star.fill").foregroundStyle(WorkSpotStyle.gold).font(.system(size: 27))
                        Text("4.3").font(.system(size: 25, weight: .semibold))
                        Text("(128 reviews)").font(.system(size: 18))
                    }
                    .foregroundStyle(WorkSpotStyle.darkGreen)
                    .frame(maxWidth: .infinity)

                    ForEach(reviews) { review in
                        ReviewRow(review: review)
                        Divider().overlay(WorkSpotStyle.gray.opacity(0.5))
                    }

                    Button { openRatePlace() } label: {
                        FormActionButton(title: "Write a review", filled: true)
                    }
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: Favorites

    private var favoritesScreen: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Favorites")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(WorkSpotStyle.darkGreen)
                .padding(.top, 18)

            if isFavorite {
                Button { openPlace() } label: {
                    HStack(spacing: 13) {
                        CafePhotoPlaceholder()
                            .frame(width: 76, height: 76)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Röstbar").font(.system(size: 19, weight: .semibold))
                            Text("4.3  ·  €€  ·  Open now").font(.system(size: 14))
                        }
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(WorkSpotStyle.darkGreen)
                    }
                    .padding(12)
                    .background(WorkSpotStyle.paleGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "heart").font(.system(size: 40)).foregroundStyle(WorkSpotStyle.green)
                    Text("No favorites yet").font(.system(size: 18, weight: .semibold)).foregroundStyle(WorkSpotStyle.darkGreen)
                    Text("Tap the heart on a place to save it here.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 80)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 90)
    }

    // MARK: Profile

    private var profileScreen: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Profile")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
                Spacer()
                Button {} label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.black)
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 30)
            .padding(.top, 22)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    Image(systemName: "person.fill")
                        .font(.system(size: 53))
                        .foregroundStyle(.black)
                        .frame(width: 122, height: 122)
                        .background(WorkSpotStyle.lightGreen)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(WorkSpotStyle.green.opacity(0.7), lineWidth: 1))
                        .padding(.top, 15)

                    Text("Alex")
                        .font(.system(size: 25, weight: .medium))
                        .foregroundStyle(WorkSpotStyle.darkGreen)
                    Text("alex@gmail.com")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(WorkSpotStyle.darkGreen)

                    VStack(spacing: 0) {
                        ProfileRow(icon: "heart.fill", title: "Favorites") {
                            selectedTab = .favorites
                            clearOverlays()
                        }
                        ProfileRow(icon: "pencil", title: "My reviews", isEnabled: false) {}
                        ProfileRow(icon: "mappin.and.ellipse", title: "My added places", isEnabled: false) {}
                        ProfileRow(icon: "rectangle.portrait.and.arrow.right", title: "Log out") {}
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 34)
                    .padding(.bottom, 110)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Bottom Navigation

    private var bottomBar: some View {
        HStack(spacing: 0) {
            BottomItem(icon: "map.fill", title: "Map", isSelected: selectedTab == .map && !showDetails && !showReviews && !showRatingScreen && !showAddPlaceScreen) {
                selectedTab = .map
                showMapPlaceCard = false
                clearOverlays()
            }
            BottomItem(icon: "heart", title: "Favorites", isSelected: selectedTab == .favorites && !showDetails && !showReviews && !showRatingScreen && !showAddPlaceScreen) {
                selectedTab = .favorites
                clearOverlays()
            }
            BottomItem(icon: "plus.circle", title: "Add", isSelected: false) {
                clearOverlays()
                showAddPlaceScreen = true
            }
            BottomItem(icon: "person", title: "Profile", isSelected: selectedTab == .profile && !showDetails && !showReviews && !showRatingScreen && !showAddPlaceScreen) {
                selectedTab = .profile
                clearOverlays()
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 7)
        .background(WorkSpotStyle.green)
        .overlay(alignment: .top) {
            Rectangle().fill(WorkSpotStyle.darkGreen.opacity(0.5)).frame(height: 1)
        }
    }

    private func openPlace() {
        selectedTab = .map
        showReviews = false
        showDetails = true
        showRatingScreen = false
        showAddPlaceScreen = false
    }

    private func openRatePlace() {
        showRatingScreen = true
        showReviews = false
    }

    private func openAddPlace() {
        clearOverlays()
        showAddPlaceScreen = true
    }

    private func clearOverlays() {
        showDetails = false
        showReviews = false
        showRatingScreen = false
        showAddPlaceScreen = false
    }
}

// MARK: Reusable components

private struct PageHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 29, weight: .semibold))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
            }
            .accessibilityLabel("Back")
            Spacer()
            Text(title)
                .font(.system(size: 25, weight: .medium))
                .foregroundStyle(WorkSpotStyle.darkGreen)
            Spacer()
            Image(systemName: "chevron.left")
                .font(.system(size: 29))
                .foregroundStyle(.clear)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }
}

private struct AddFieldLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(WorkSpotStyle.darkGreen)
            .padding(.top, 1)
    }
}

private struct FormActionButton: View {
    let title: String
    var filled = false

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(filled ? .white : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(filled ? WorkSpotStyle.green : WorkSpotStyle.lightGreen)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(WorkSpotStyle.green, lineWidth: 1))
    }
}

private struct BottomItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                    .frame(height: 27)
                Text(title).font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .black)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct MapPin: View {
    let symbol: String
    let color: Color

    var body: some View {
        VStack(spacing: -3) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(color)
                .clipShape(Circle())
            Image(systemName: "triangle.fill")
                .font(.system(size: 10))
                .foregroundStyle(color)
                .rotationEffect(.degrees(180))
        }
        .shadow(color: .black.opacity(0.14), radius: 2, y: 1)
    }
}

private struct MapArtwork: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.94, green: 0.94, blue: 0.90)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.77, green: 0.87, blue: 0.68))
                    .frame(width: geo.size.width * 0.34, height: 90)
                    .position(x: geo.size.width * 0.76, y: 65)

                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.77, green: 0.87, blue: 0.68))
                    .frame(width: 130, height: 76)
                    .rotationEffect(.degrees(-28))
                    .position(x: geo.size.width * 0.40, y: geo.size.height * 0.67)

                Path { path in
                    path.move(to: CGPoint(x: -30, y: 0))
                    path.addCurve(to: CGPoint(x: 45, y: geo.size.height * 0.38),
                                  control1: CGPoint(x: 80, y: geo.size.height * 0.12),
                                  control2: CGPoint(x: -15, y: geo.size.height * 0.23))
                    path.addCurve(to: CGPoint(x: 90, y: geo.size.height),
                                  control1: CGPoint(x: 5, y: geo.size.height * 0.60),
                                  control2: CGPoint(x: 110, y: geo.size.height * 0.78))
                    path.addLine(to: CGPoint(x: 130, y: geo.size.height))
                    path.addCurve(to: CGPoint(x: 83, y: geo.size.height * 0.58),
                                  control1: CGPoint(x: 125, y: geo.size.height * 0.82),
                                  control2: CGPoint(x: 30, y: geo.size.height * 0.67))
                    path.addCurve(to: CGPoint(x: 88, y: geo.size.height * 0.20),
                                  control1: CGPoint(x: 45, y: geo.size.height * 0.40),
                                  control2: CGPoint(x: 120, y: geo.size.height * 0.28))
                    path.addLine(to: CGPoint(x: 30, y: 0))
                    path.closeSubpath()
                }
                .fill(Color(red: 0.58, green: 0.79, blue: 0.91))

                ForEach(0..<6, id: \.self) { i in
                    Rectangle()
                        .fill(.white)
                        .frame(height: 8)
                        .position(x: geo.size.width / 2, y: CGFloat(i) * geo.size.height / 5)
                    Rectangle()
                        .fill(.white)
                        .frame(width: 8)
                        .position(x: CGFloat(i) * geo.size.width / 5, y: geo.size.height / 2)
                }

                Path { path in
                    path.move(to: CGPoint(x: 95, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width * 0.75, y: geo.size.height * 0.55))
                    path.addLine(to: CGPoint(x: geo.size.width * 0.45, y: geo.size.height))
                }
                .stroke(.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
            }
        }
    }
}

private struct CafePhotoPlaceholder: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.70, blue: 0.55),
                    Color(red: 0.45, green: 0.35, blue: 0.25),
                    Color(red: 0.88, green: 0.79, blue: 0.63)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            HStack(alignment: .bottom, spacing: 12) {
                VStack(spacing: 5) {
                    Rectangle().fill(Color(red: 0.30, green: 0.20, blue: 0.14)).frame(height: 30)
                    Rectangle().fill(Color(red: 0.57, green: 0.40, blue: 0.25)).frame(height: 45)
                    Rectangle().fill(Color(red: 0.25, green: 0.18, blue: 0.12)).frame(height: 25)
                }
                .frame(width: 65)

                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle()
                                .fill(Color(red: 0.93, green: 0.83, blue: 0.64))
                                .frame(height: 60)
                                .overlay(Rectangle().stroke(Color.white.opacity(0.45), lineWidth: 3))
                        }
                    }
                    Rectangle().fill(Color(red: 0.27, green: 0.18, blue: 0.12)).frame(height: 12)
                    Spacer()
                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Image(systemName: "chair.lounge.fill")
                                .font(.system(size: 23))
                                .foregroundStyle(Color(red: 0.35, green: 0.22, blue: 0.13))
                        }
                    }
                    .padding(.bottom, 9)
                }

                VStack {
                    Circle().fill(Color(red: 0.25, green: 0.44, blue: 0.25)).frame(width: 35, height: 35)
                    Rectangle().fill(Color(red: 0.35, green: 0.23, blue: 0.15)).frame(width: 5, height: 80)
                }
            }
            .padding(12)
        }
    }
}

private struct StarScaleRow: View {
    let icon: String
    let title: String
    @Binding var rating: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(.black)
                    .frame(width: 30)
                Text(title)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
            }

            HStack(spacing: 7) {
                ForEach(1...5, id: \.self) { star in
                    Button { rating = star } label: {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 30))
                            .foregroundStyle(star <= rating ? WorkSpotStyle.gold : WorkSpotStyle.gray)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(star) out of 5 stars")
                }
            }
            .padding(.leading, 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RatingRow: View {
    let icon: String
    let title: String
    let rating: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.black)
                .frame(width: 25)
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(WorkSpotStyle.darkGreen)
            Spacer(minLength: 4)
            HStack(spacing: 1) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: 19))
                        .foregroundStyle(index <= rating ? WorkSpotStyle.gold : WorkSpotStyle.gray)
                }
            }
        }
    }
}

private struct ReviewRow: View {
    let review: Review

    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.gray.opacity(0.55))
                .frame(width: 45)

            VStack(alignment: .leading, spacing: 5) {
                Text(review.name)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
                Text(review.date)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)

                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 16))
                            .foregroundStyle(index <= review.rating ? WorkSpotStyle.gold : WorkSpotStyle.gray)
                    }
                }

                Text(review.text)
                    .font(.system(size: 15))
                    .foregroundStyle(WorkSpotStyle.darkGreen)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 3)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    private var rowContent: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .frame(width: 28)
                .foregroundStyle(.black)
            Text(title)
                .font(.system(size: 19, weight: .medium))
                .foregroundStyle(WorkSpotStyle.darkGreen)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(WorkSpotStyle.darkGreen)
        }
        .padding(.vertical, 19)
        .contentShape(Rectangle())
    }

    var body: some View {
        Group {
            if isEnabled {
                Button(action: action) {
                    rowContent
                }
                .buttonStyle(.plain)
            } else {
                // Keep the same colors and layout, but render as a non-interactive row.
                rowContent
            }
        }
    }
}

private extension View {
    func workSpotInput() -> some View {
        self
            .font(.system(size: 15))
            .foregroundStyle(WorkSpotStyle.green)
            .padding(.horizontal, 14)
            .frame(height: 54)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(WorkSpotStyle.green, lineWidth: 2))
    }
}

private struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var placeType = "All"
    @State private var price = "Any"
    @State private var quietOnly = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Show", selection: $placeType) {
                        Text("All").tag("All")
                        Text("Cafés").tag("Cafés")
                        Text("Coworking").tag("Coworking")
                        Text("Libraries").tag("Libraries")
                    }
                }
                Section("Price") {
                    Picker("Price level", selection: $price) {
                        Text("Any").tag("Any")
                        Text("Free").tag("Free")
                        Text("€").tag("€")
                        Text("€€").tag("€€")
                        Text("€€€").tag("€€€")
                    }
                }
                Section {
                    Toggle("Quiet places only", isOn: $quietOnly)
                        .tint(WorkSpotStyle.green)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
