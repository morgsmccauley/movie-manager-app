//
//  MovieSearchTableViewController.swift
//  movie-manager-app
//
//  Created by Morgan McCauley on 1/10/17.
//  Copyright © 2017 Morgan McCauley. All rights reserved.
//

import UIKit

private let DEFAULT_ROW_HEIGHT = CGFloat(211);

class MovieSearchTableViewController: UITableViewController, UISearchBarDelegate, MovieManagerDelegate{
    @IBOutlet weak var searchBar: UISearchBar!;

    let movieManager = MovieManager();

    var searchText: String = "" {
        didSet {
            if (!searchText.isEmpty) {
                executeDelayedSearch(text: searchText);
            } else {
                clearSearchResults();
            }
        }
    }

    var searchResults: [Movie] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView!.reloadData();
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = DEFAULT_ROW_HEIGHT;

        searchBar.delegate = self;
        movieManager.delegate = self;
    }
    
    func executeDelayedSearch(text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let isLatestSearchText = self.searchText == text;
            if (isLatestSearchText) {
                print("executing search: " + self.searchText)
                self.movieManager.fetchMoviesFor(query: self.searchText);
            }
        }
    }

    func movieFetchComplete(movies: [Movie]) {
        searchResults = movies;
    }
    
    func clearSearchResults() {
        searchResults = [];
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard();
    }
    
    func dismissKeyboard() {
        if (self.searchBar.isFirstResponder) {
            print("dismiss keyboard");
            DispatchQueue.main.async {
                self.searchBar.endEditing(true);
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard();
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! MovieSearchTableViewCell;

        let movieForRow = searchResults[(indexPath as NSIndexPath).row];

        row.movieTitle?.text = movieForRow.title;
        row.releaseDate?.text = movieForRow.releaseDate;

        row.setUpView();

        let backdropPath = movieForRow.backdropPath;
        movieManager.fetchImage(path: backdropPath) { backdrop in
            DispatchQueue.main.async {
                if let backdrop = backdrop {
                    row.backdrop.image = backdrop;
                }
            }
        }

        return row
    }
}
