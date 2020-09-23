//
//  ContentView.swift
//  JSON Parse
//
//  Created by Admin on 7/23/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Home()
                .navigationTitle("GitHub Users")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @State var users: [JSONData] = []
    
    var body: some View {
        VStack {
            if users.isEmpty {
                // loading View...
                Spacer()
                ProgressView()
                Spacer()
            } else {
                // displaying users...
                List(users) { user in
                   NavigationLink(
                    destination: DetailView(user: user),
                    label: {
                        RowView(user: user)
                    })
                }
                // listStyle...
                .listStyle(InsetGroupedListStyle())
            }
        }
        // refresh Button...
        .navigationBarItems(trailing:
                                Button(action: {
                                    users.removeAll()
                                    getUserData(url: "https://api.github.com/users") { (users) in
                                        self.users = users
                                    }
                                }, label: {
                                    Image(systemName: "arrow.clockwise")
                                })
        )
        .onAppear {
            // loading users data...
            getUserData(url: "https://api.github.com/users") { (users) in
                self.users = users
            }
        }
    }
}

// User View...
struct RowView: View {
    
    var user: JSONData
    
    var body: some View {
        HStack {
            AnimatedImage(url: URL(string: user.avatar_url)!)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .shadow(radius: 5)
            
            Text(user.login)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .padding(.vertical, 5)
    }
}

// DetailView...
struct DetailView: View {
    
    var user: JSONData
    @State var followers: [JSONData] = []
    @State var isEmpty = false
    
    var body: some View {
        VStack {
            if followers.isEmpty {
                Spacer()
                if isEmpty {
                    Text("No Followers")
                        .fontWeight(.bold)
                } else {
                    ProgressView()
                }
                Spacer()
            } else {
                List {
                    Text("Followers")
                    
                    ForEach(followers) { user in
                        RowView(user: user)
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle(user.login)
        .onAppear {
            // loading user followers data...
            getUserData(url: user.followers_url) { (followers) in
                if followers.isEmpty {
                    isEmpty = true
                } else {
                    self.followers = followers
                }
            }
        }
    }
}

// Model...
struct JSONData: Identifiable, Decodable {
    var id: Int
    var login: String
    var avatar_url: String
    var followers_url: String
}

// returning array of user data...
func getUserData(url: String, completion: @escaping ([JSONData]) -> ()) {
    let session = URLSession(configuration: .default)
    session.dataTask(with: URL(string: url)!) { (data, _, error) in
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        // decoding JSON
        do {
            let users = try JSONDecoder().decode([JSONData].self, from: data!)
            // returning users...
            completion(users)
        } catch {
            print(error)
        }
    }
    .resume()
}

