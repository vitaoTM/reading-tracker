# 📚 Reading Tracker

A modern, full-featured **Ruby on Rails 8.1** application designed to help users track their reading journeys, cultivate healthy reading habits, organize their personal library, and manage book loans.

---

## ✨ Features

- **🔒 Custom Authentication:** A session-based authentication system built using `bcrypt`.
- **📖 Personal Library:** Maintain a list of books with detailed metadata (Author, ISBN, description, language, page count, country of origin, and age indicator).
- **🔄 Status Tracking:** Group books under `Want to Read`, `Reading`, and `Finished` statuses.
- **📥 Amazon Wishlist Importer:**
  - Import books directly via a public Amazon Wishlist URL (HTML scraper).
  - Bulk import books using Amazon Wishlist CSV export files.
* **📈 Reading Habits:**
  - Log pages read and time spent (in minutes) per session.
  - Track metrics (total pages/minutes, active days, current consecutive day streak).
  - Visualize progress via a **90-day interactive activity heatmap**.
* **🤝 Book Loans:** Record books borrowed from or lent to others. Manage open/closed status, loan dates, and return dates.
* **⭐ Ratings & Reviews:** Rate books (1-5 stars) and write text reviews. Average ratings and review counts are cached directly on book records for efficiency.
* **🏷️ Book Tagging:** Categorize your books with custom hashtags (`#genre`, `#topic`) using a simple comma-separated entry interface.
* **🏆 Favorite Shelf:** Curate a top 20 list of your favorite books and arrange their order dynamically.

---

## 🛠️ Technology Stack

- **Ruby Version:** `4.0.1` (declared in `.ruby-version`)
- **Framework:** Ruby on Rails `8.1`
- **Database:** PostgreSQL
- **Frontend:** Hotwire (`Turbo`, `Stimulus`), Tailwind CSS (`tailwindcss-rails`, custom presets in `app/assets/tailwind/application.css`), `importmap-rails`
- **Job Queue:** Solid Queue (active jobs)
- **Testing:** Minitest, Capybara (system tests), and WebMock (external API stubbing)

---

## 🚀 Getting Started

Follow these steps to set up and run the application locally:

### 1. Prerequisites
Ensure you have **Ruby 4.0.1** and **PostgreSQL** installed on your system.

### 2. Install Dependencies
Clone the repository, navigate into the directory, and run bundler:
```bash
bundle install
```

### 3. Database Setup
Configure your database credentials (if necessary) in `config/database.yml`. Then create and migrate the database:
```bash
bin/rails db:create
bin/rails db:migrate
```

### 4. Run the Development Server
This project uses `foreman` to run both the Puma web server and the Tailwind watcher in parallel. Start it with the helper script:
```bash
bin/dev
```
The application will be accessible at `http://localhost:3000`.

### 5. Running the Test Suite
Execute the test suite (covering models, controllers, and services) with:
```bash
bin/rails test
```

---

## 📂 Core Database Schema & Models

The architecture is built around several models mapping user interactions:
- [User](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/user.rb) — Manages secure passwords, credentials, reading streaks, and statistics.
- [Book](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/book.rb) — Represents metadata, handles tags, and caches average ratings.
- [ReadingEntry](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/reading_entry.rb) — Connects a User to a Book with a status (want to read, reading, finished) and notes.
- [ReadingSession](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/reading_session.rb) — Tracks dates, duration, and page progress for habits tracking.
- [Loan](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/loan.rb) — Stores borrower/lender directions, names, dates, and returned statuses.
- [Rating](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/rating.rb) — Handles user score evaluations (1-5) and reviews.
- [FavoriteBook](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/favorite_book.rb) — Tracks user favorites (max 20) and display sequencing.
- [Tag](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/tag.rb) & [BookTag](file:///home/vitaotm/Documents/reading_tracker/reading_tracker/app/models/book_tag.rb) — Many-to-many associations for categorization.
