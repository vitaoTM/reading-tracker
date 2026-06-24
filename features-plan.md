# Features Plan — Step-by-Step Execution Guide

Each step takes < 1 minute. Check off as you go.

**Legend:** `FILE:LINE` = open that file, go to that line. Code blocks show the exact text to type/paste.

---

## Track 7a · Fix: Book delete crashes (Active Storage tables missing)

**Root cause:** `Book` uses `has_one_attached :cover_image` but Active Storage was never installed. Delete triggers a join on `active_storage_attachments` which doesn't exist.

- [ ] **Step 1** — In terminal, run:
  ```
  bin/rails active_storage:install
  ```
  This generates a migration file under `db/migrate/`.

- [ ] **Step 2** — In terminal, run:
  ```
  bin/rails db:migrate
  ```
  You should see three tables created: `active_storage_blobs`, `active_storage_attachments`, `active_storage_variant_records`.

- [ ] **Step 3** — Verify: visit any book's page and click "Destroy this book". No crash.

- [ ] **Step 4** — Commit:
  ```
  git add db/migrate db/schema.rb
  git commit -m "fix(db): install active_storage migrations"
  ```

---

## Track 7b · Fix: Amazon wishlist imports non-book items

**Root cause:** The importer imports every `li[data-itemid]` element regardless of type. Books have a `"by Author"` line; tools/appliances don't.

- [ ] **Step 1** — Open `app/services/amazon_wishlist_importer.rb` at **line 25**.

  Find this block (lines 25–33):
  ```ruby
        author_node = li.at_css("span.a-size-base")
        img_node    = li.at_css("img")

        items << Item.new(
          title:     title_node.text.strip,
          author:    author_node&.text&.gsub(/^by\s+/i, "")&.strip,
          asin:      li["data-itemid"],
          image_url: img_node&.[]("src")
        )
  ```

  Replace it with:
  ```ruby
        author_node = li.at_css("span.a-size-base")
        img_node    = li.at_css("img")
        author_text = author_node&.text&.strip
        next unless author_text&.match?(/\Aby\s+\S/i)

        items << Item.new(
          title:     title_node.text.strip,
          author:    author_text.sub(/^by\s+/i, "").strip,
          asin:      li["data-itemid"],
          image_url: img_node&.[]("src")
        )
  ```

- [ ] **Step 2** — Open `test/services/amazon_wishlist_importer_test.rb` at **line 43**.

  Inside `amazon_wishlist_html_fixture`, after the second `</li>` (line 51) and before `</ul>`, add a third item with no "by" author:
  ```html
            <li data-itemid="ASIN003">
              <a id="itemName_ASIN003">Black &amp; Decker Drill</a>
              <span class="a-size-base">Electronics</span>
              <img src="https://example.com/drill.jpg" />
            </li>
  ```

- [ ] **Step 3** — Still in `test/services/amazon_wishlist_importer_test.rb`, after the `test "skips books user already has"` block (after line 33), add a new test:
  ```ruby
    test "skips non-book items without a 'by Author' line" do
      count = AmazonWishlistImporter.new(@url).import_for(@user)
      assert_equal 2, count
      assert_nil Book.find_by(title: "Black & Decker Drill")
    end
  ```

- [ ] **Step 4** — Run the service tests:
  ```
  bin/rails test test/services/amazon_wishlist_importer_test.rb
  ```
  All tests should pass.

- [ ] **Step 5** — Commit:
  ```
  git add app/services/amazon_wishlist_importer.rb test/services/amazon_wishlist_importer_test.rb
  git commit -m "fix(import): filter non-book items from Amazon wishlist by author presence"
  ```

---

## Track 1 · Test Review: Add Missing Model Tests

- [ ] **Step 1** — Open `test/models/book_test.rb`. After the last `test "..." do` block, add:
  ```ruby
    test "country_of_origin is optional" do
      book = build(:book, country_of_origin: nil)
      assert book.valid?
    end

    test "country_of_origin is stored as entered" do
      book = create(:book, country_of_origin: "BR")
      assert_equal "BR", book.reload.country_of_origin
    end
  ```

- [ ] **Step 2** — Run book model tests:
  ```
  bin/rails test test/models/book_test.rb
  ```

- [ ] **Step 3** — Commit:
  ```
  git add test/models/book_test.rb
  git commit -m "feat(tests): add missing country_of_origin coverage to BookTest"
  ```

---

## Track 2 · Auto-fill Map Colors from Reading Status

### Migration

- [ ] **Step 1** — In terminal:
  ```
  bin/rails g migration AddAutoFilledToMapEntries auto_filled:boolean
  ```

- [ ] **Step 2** — Open the generated file at `db/migrate/*_add_auto_filled_to_map_entries.rb`.

  The generator creates:
  ```ruby
  add_column :map_entries, :auto_filled, :boolean
  ```
  Change it to:
  ```ruby
  add_column :map_entries, :auto_filled, :boolean, default: false, null: false
  ```

- [ ] **Step 3** — In terminal:
  ```
  bin/rails db:migrate
  ```

### MapEntry model — add color constants

- [ ] **Step 4** — Open `app/models/map_entry.rb` at **line 2** (after `COUNTRY_CODE_REGEX`). Insert these three lines immediately after line 2:
  ```ruby
    READING_COLOR  = "#f59e0b"
    FINISHED_COLOR = "#10b981"
    STATUS_COLORS  = { "reading" => READING_COLOR, "finished" => FINISHED_COLOR }.freeze
  ```

### Service

- [ ] **Step 5** — Create new file `app/services/map_entry_auto_filler.rb` with this exact content:
  ```ruby
  class MapEntryAutoFiller
    def self.call(reading_entry) = new(reading_entry).call

    def initialize(reading_entry)
      @re = reading_entry
    end

    def call
      return unless @re.reading? || @re.finished?

      code = @re.book.country_of_origin&.strip&.upcase
      return unless code&.match?(/\A[A-Z]{2}\z/)

      entry = @re.user.map_entries.find_or_initialize_by(country_code: code)
      if entry.new_record?
        entry.assign_attributes(
          color: MapEntry::STATUS_COLORS[@re.status],
          auto_filled: true,
          book_id: @re.book_id
        )
        entry.save
      elsif entry.auto_filled? && entry.book_id == @re.book_id
        entry.update(color: MapEntry::STATUS_COLORS[@re.status])
      end
    end
  end
  ```

### ReadingEntry callback

- [ ] **Step 6** — Open `app/models/reading_entry.rb`. After `validates :status, presence: true` (the last line before `end`), add:
  ```ruby

    after_save :sync_map_entry

    private

    def sync_map_entry
      MapEntryAutoFiller.call(self)
    end
  ```

### Controller — mark manual saves

- [ ] **Step 7** — Open `app/controllers/map_entries_controller.rb` at **line 11**.

  Find:
  ```ruby
      entry.assign_attributes(color: params[:color], book_id: params[:book_id].presence)
  ```
  Change to:
  ```ruby
      entry.assign_attributes(color: params[:color], book_id: params[:book_id].presence, auto_filled: false)
  ```

### Tests

- [ ] **Step 8** — Create `test/services/map_entry_auto_filler_test.rb`:
  ```ruby
  require "test_helper"

  class MapEntryAutoFillerTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
      @book = create(:book, country_of_origin: "BR")
    end

    test "creates amber map entry when book marked reading" do
      @user.reading_entries.create!(book: @book, status: :reading)
      entry = @user.map_entries.find_by(country_code: "BR")
      assert entry, "Expected a MapEntry for BR"
      assert_equal MapEntry::READING_COLOR, entry.color
      assert entry.auto_filled
    end

    test "creates green map entry when book marked finished" do
      @user.reading_entries.create!(book: @book, status: :finished)
      assert_equal MapEntry::FINISHED_COLOR, @user.map_entries.find_by(country_code: "BR").color
    end

    test "updates color when same book moves from reading to finished" do
      re = @user.reading_entries.create!(book: @book, status: :reading)
      re.update!(status: :finished)
      assert_equal MapEntry::FINISHED_COLOR, @user.map_entries.find_by(country_code: "BR").color
    end

    test "does not overwrite a manual map entry" do
      create(:map_entry, user: @user, country_code: "BR", color: "#123456", auto_filled: false)
      @user.reading_entries.create!(book: @book, status: :finished)
      assert_equal "#123456", @user.map_entries.find_by(country_code: "BR").color
    end

    test "skips books with non-ISO country_of_origin" do
      book = create(:book, country_of_origin: "Brazil")
      @user.reading_entries.create!(book: book, status: :finished)
      assert_equal 0, @user.map_entries.count
    end

    test "skips want_to_read and dnf status" do
      @user.reading_entries.create!(book: @book, status: :want_to_read)
      assert_equal 0, @user.map_entries.count
    end

    test "skips books with no country_of_origin" do
      book = create(:book, country_of_origin: nil)
      @user.reading_entries.create!(book: book, status: :finished)
      assert_equal 0, @user.map_entries.count
    end
  end
  ```

- [ ] **Step 9** — Open `test/models/map_entry_test.rb`. After the last test block, add:
  ```ruby
    test "auto_filled defaults to false" do
      entry = create(:map_entry)
      refute entry.auto_filled
    end
  ```

- [ ] **Step 10** — Run tests:
  ```
  bin/rails test test/services/map_entry_auto_filler_test.rb test/models/map_entry_test.rb
  ```

### Book form hint

- [ ] **Step 11** — Open `app/views/books/_form.html.erb` at **line 68** (the `country_of_origin` field). After `form.text_field :country_of_origin`, add a hint line:
  ```erb
      <p class="mt-1 text-xs text-slate-400">Use 2-letter ISO code (e.g. BR, GB, JP) to enable map auto-fill.</p>
  ```

- [ ] **Step 12** — Commit:
  ```
  git add db/migrate db/schema.rb app/models/map_entry.rb app/models/reading_entry.rb \
          app/services/map_entry_auto_filler.rb app/controllers/map_entries_controller.rb \
          app/views/books/_form.html.erb \
          test/services/map_entry_auto_filler_test.rb test/models/map_entry_test.rb
  git commit -m "feat(map): auto-fill country color from reading status"
  ```

---

## Track 3 · Show Book Count Per Country

### User model

- [ ] **Step 1** — Open `app/models/user.rb` at **line 61** (after `map_data` method, before final `end`). Add:
  ```ruby

    def books_per_country
      reading_entries
        .where(status: [ :reading, :finished ])
        .joins(:book)
        .where.not(books: { country_of_origin: [ nil, "" ] })
        .pluck("UPPER(books.country_of_origin)")
        .tally
        .select { |code, _| code.match?(/\A[A-Z]{2}\z/) }
    end
  ```

### Controllers

- [ ] **Step 2** — Open `app/controllers/profiles_controller.rb` at **line 10** (after `@map_data` line). Add:
  ```ruby
      @books_per_country = @user.books_per_country
  ```

- [ ] **Step 3** — Open `app/controllers/map_entries_controller.rb` at **line 6** (after `@filled` line in `#index`). Add:
  ```ruby
      @books_per_country = Current.user.books_per_country
  ```

### Profile view badges

- [ ] **Step 4** — Open `app/views/profiles/show.html.erb` at **line 124**. Find:
  ```erb
                📍 <%= code %>
  ```
  Replace with:
  ```erb
                📍 <%= code %>
                <% if @books_per_country[code].to_i > 0 %>
                  <span class="opacity-75 text-[10px] font-normal"><%= @books_per_country[code] %></span>
                <% end %>
  ```

### Map page badges

- [ ] **Step 5** — Open `app/views/map_entries/index.html.erb` at **line 39**. Find:
  ```erb
                  <%= entry.country_code %>
  ```
  Replace with:
  ```erb
                  <%= entry.country_code %>
                  <% if @books_per_country[entry.country_code].to_i > 0 %>
                    <span class="opacity-75 text-[10px] font-normal"><%= @books_per_country[entry.country_code] %></span>
                  <% end %>
  ```

### Map panel — add count element

- [ ] **Step 6** — Open `app/views/map_entries/index.html.erb` at **line 16**. Find:
  ```erb
        <h3 class="font-bold text-slate-800 text-sm" id="map-panel-title">Country</h3>
  ```
  After that line, add:
  ```erb
        <p class="text-xs text-slate-500" id="map-panel-count"></p>
  ```

### Map view — pass counts to Stimulus

- [ ] **Step 7** — Open `app/views/map_entries/index.html.erb` at **line 10**. Find:
  ```erb
          data-world-map-save-url-value="<%= map_entries_path %>"
  ```
  After that line, add:
  ```erb
          data-world-map-counts-value="<%= @books_per_country.to_json %>"
  ```

### Stimulus controller — receive and display counts

- [ ] **Step 8** — Open `app/javascript/controllers/world_map_controller.js` at **line 4**. Find:
  ```js
      static values = { filled: Object, saveUrl: String }
  ```
  Replace with:
  ```js
      static values = { filled: Object, saveUrl: String, counts: Object }
  ```

- [ ] **Step 9** — In the same file, inside `handleClick`, after:
  ```js
        const existing = this.filledValue[code]
        if (existing) document.getElementById("map-color-picker").value = existing
  ```
  Add:
  ```js
        const count = this.countsValue[code]
        const countEl = document.getElementById("map-panel-count")
        if (countEl) countEl.textContent = count ? `${count} book${count !== 1 ? "s" : ""} from here` : ""
  ```

- [ ] **Step 10** — Run tests, then commit:
  ```
  bin/rails test
  git add app/models/user.rb app/controllers/profiles_controller.rb \
          app/controllers/map_entries_controller.rb \
          app/views/profiles/show.html.erb app/views/map_entries/index.html.erb \
          app/javascript/controllers/world_map_controller.js
  git commit -m "feat(map): show book count per country on map and profile"
  ```

---

## Track 4 · Map Zoom Controls

### Stimulus controller

- [ ] **Step 1** — Open `app/javascript/controllers/world_map_controller.js` at **line 4**. Find (the static values line you edited in Track 3):
  ```js
      static values = { filled: Object, saveUrl: String, counts: Object }
  ```
  Replace with:
  ```js
      static values = { filled: Object, saveUrl: String, counts: Object, zoom: { type: Number, default: 1 } }
  ```

- [ ] **Step 2** — In the same file, after the `findPath(code)` method (the last method, currently at line 81), add these new methods before the closing `}`:
  ```js

      zoomIn()  { this.zoomValue = Math.min(this.zoomValue * 1.5, 6) }
      zoomOut() { this.zoomValue = Math.max(this.zoomValue / 1.5, 1) }
      zoomReset() { this.zoomValue = 1 }

      zoomValueChanged() {
        const svg = this.element.querySelector("svg")
        if (!svg) return
        if (this.zoomValue === 1) {
          svg.style.width = ""
          svg.style.height = ""
        } else {
          svg.style.width = `${this.element.offsetWidth * this.zoomValue}px`
          svg.style.height = "auto"
        }
      }
  ```

### Map view — zoom buttons

- [ ] **Step 3** — Open `app/views/map_entries/index.html.erb` at **line 11** (the line that starts the `overflow-x-auto` div wrapping the SVG). Add these zoom controls immediately BEFORE that div:
  ```erb
      <div class="flex items-center gap-2 mb-3">
        <button data-action="world-map#zoomIn"    class="btn-secondary py-1 px-3 text-sm font-bold">+</button>
        <button data-action="world-map#zoomOut"   class="btn-secondary py-1 px-3 text-sm font-bold">−</button>
        <button data-action="world-map#zoomReset" class="btn-secondary py-1 px-3 text-xs">Reset</button>
      </div>
  ```

- [ ] **Step 4** — Commit:
  ```
  git add app/javascript/controllers/world_map_controller.js app/views/map_entries/index.html.erb
  git commit -m "feat(map): add zoom in/out controls"
  ```

---

## Track 5 · Mobile Responsiveness

### Mobile nav Stimulus controller

- [ ] **Step 1** — Create new file `app/javascript/controllers/mobile_nav_controller.js`:
  ```js
  import { Controller } from "@hotwired/stimulus"

  export default class extends Controller {
    static targets = ["menu"]

    toggle() {
      this.menuTarget.classList.toggle("hidden")
    }

    close() {
      this.menuTarget.classList.add("hidden")
    }
  }
  ```
  (Auto-loaded — no need to edit `index.js`.)

### Navbar

- [ ] **Step 2** — Open `app/views/shared/_navbar.html.erb` at **line 1**. Find:
  ```erb
  <header class="sticky top-0 z-50 w-full bg-slate-200 backdrop-blur-md border-b border-slate-200/80 shadow-sm">
  ```
  Replace with:
  ```erb
  <header class="sticky top-0 z-50 w-full bg-slate-200 backdrop-blur-md border-b border-slate-200/80 shadow-sm"
          data-controller="mobile-nav">
  ```

- [ ] **Step 3** — Still in `_navbar.html.erb`, find the closing line of the right-side div (after the sign out button, around **line 62**):
  ```erb
      </div>
    </div>
  </div>
  ```
  Before the FIRST `</div>` above (the one that closes `flex items-center gap-3`), add:
  ```erb
          <% if authenticated? %>
            <button data-action="mobile-nav#toggle"
                    class="md:hidden p-2 rounded-lg text-slate-600 hover:bg-slate-100 transition cursor-pointer"
                    aria-label="Toggle menu">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          <% end %>
  ```

- [ ] **Step 4** — Still in `_navbar.html.erb`, after the `</div>` that closes the `h-16` inner div (after line 67), and before the closing `</div>` of `max-w-7xl`, add the mobile menu panel:
  ```erb
      <% if authenticated? %>
        <div class="hidden md:hidden border-t border-slate-300/50 py-2 space-y-1"
             data-mobile-nav-target="menu">
          <%= link_to "My Library",     library_path,      class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Favorite Book",  favorites_path,    class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Discover",       books_path,        class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Want to Read",   want_to_read_path, class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Habits",         habits_path,       class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Loans",          loans_path,        class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
          <%= link_to "Map",            map_path,          class: "block px-3 py-2 rounded-lg text-sm font-semibold text-slate-700 hover:bg-slate-100 hover:text-indigo-600 transition", data: { action: "mobile-nav#close" } %>
        </div>
      <% end %>
  ```

### Layout — reduce top margin on mobile

- [ ] **Step 5** — Open `app/views/layouts/application.html.erb` at **line 30**. Find:
  ```erb
      <main class="container mx-auto mt-28 px-5 flex justify-center">
  ```
  Replace with:
  ```erb
      <main class="container mx-auto mt-20 md:mt-28 px-5 flex justify-center">
  ```

### Map panel — fix layout on small screens

- [ ] **Step 6** — Open `app/views/map_entries/index.html.erb`. Find the `map-panel` div (around line 14):
  ```erb
    <div id="map-panel" class="hidden mt-6 p-4 border border-slate-200 rounded-xl bg-slate-50 flex items-center justify-between gap-4">
  ```
  Replace with:
  ```erb
    <div id="map-panel" class="hidden mt-6 p-4 border border-slate-200 rounded-xl bg-slate-50 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
  ```

- [ ] **Step 7** — Commit:
  ```
  git add app/javascript/controllers/mobile_nav_controller.js \
          app/views/shared/_navbar.html.erb \
          app/views/layouts/application.html.erb \
          app/views/map_entries/index.html.erb
  git commit -m "feat(ui): add mobile-responsive navbar with hamburger menu"
  ```

---

## Track 6 · Hotwire: Inline #new and #edit Forms

The pattern: wrap the "New X" link in a `turbo_frame_tag` in the index. Wrap the form in the same frame in the `new` view. Clicking the link loads the form inline without a full page reload. On success, the controller's `redirect_to` navigates the full page (Turbo Drive). On validation failure (422), the form re-renders inline with errors.

### Books — #new inline

- [ ] **Step 1** — Open `app/views/books/index.html.erb` at **line 6**. Find:
  ```erb
      <%= link_to "New book", new_book_path, class: "btn-primary" %>
  ```
  Replace with:
  ```erb
      <%= turbo_frame_tag "book_form" do %>
        <%= link_to "New book", new_book_path, class: "btn-primary" %>
      <% end %>
  ```

- [ ] **Step 2** — Open `app/views/books/new.html.erb`. Replace the entire file content with:
  ```erb
  <% content_for :title, "New book" %>

  <%= turbo_frame_tag "book_form" do %>
    <div class="w-full max-w-3xl">
      <h1 class="h1 mb-8">New book</h1>
      <div class="card">
        <%= render "form", book: @book %>
      </div>
    </div>
  <% end %>
  ```

### Books — #edit inline from #show

- [ ] **Step 3** — Open `app/views/books/show.html.erb` at **line 4**. Find the opening tag:
  ```erb
    <div class="mb-8">
  ```
  Replace with:
  ```erb
    <%= turbo_frame_tag dom_id(@book) do %>
    <div class="mb-8">
  ```
  Then find the closing `</div>` of that `mb-8` block (it closes at **line 37**, after the tags section). After that `</div>`, add:
  ```erb
    <% end %>
  ```

- [ ] **Step 4** — Open `app/views/books/edit.html.erb`. Replace the entire file content with:
  ```erb
  <% content_for :title, "Editing book" %>

  <%= turbo_frame_tag dom_id(@book) do %>
    <div class="w-full max-w-3xl">
      <h1 class="h1 mb-8">Editing book</h1>
      <div class="card">
        <%= render "form", book: @book %>
      </div>
    </div>
  <% end %>
  ```

### Loans — #new inline

- [ ] **Step 5** — Open `app/views/loans/index.html.erb` at **line 7**. Find:
  ```erb
      <%= link_to "Record a Loan", new_loan_path, class: "btn-primary shadow-indigo-100 font-semibold" %>
  ```
  Replace with:
  ```erb
      <%= turbo_frame_tag "loan_form" do %>
        <%= link_to "Record a Loan", new_loan_path, class: "btn-primary shadow-indigo-100 font-semibold" %>
      <% end %>
  ```

- [ ] **Step 6** — Open `app/views/loans/new.html.erb`. Replace the entire file content with:
  ```erb
  <%= turbo_frame_tag "loan_form" do %>
    <div class="max-w-xl mx-auto py-6">
      <div class="mb-8 text-center">
        <h1 class="h1">Record a Book Loan</h1>
        <p class="mt-2 text-slate-600">Enter loan details to track lending or borrowing activity.</p>
      </div>
      <div class="card p-6 sm:p-8">
        <%= render "form", loan: @loan %>
      </div>
    </div>
  <% end %>
  ```

### Recommendation Lists — #new inline

- [ ] **Step 7** — Open `app/views/recommendation_lists/index.html.erb` at **line 7**. Find:
  ```erb
      <%= link_to "New List", new_recommendation_list_path, class: "btn-primary shadow-indigo-100" %>
  ```
  Replace with:
  ```erb
      <%= turbo_frame_tag "recommendation_list_form" do %>
        <%= link_to "New List", new_recommendation_list_path, class: "btn-primary shadow-indigo-100" %>
      <% end %>
  ```

- [ ] **Step 8** — Open `app/views/recommendation_lists/new.html.erb`. Replace the entire file content with:
  ```erb
  <%= turbo_frame_tag "recommendation_list_form" do %>
    <div class="w-full max-w-3xl">
      <h1 class="text-2xl font-bold mb-4">New List</h1>
      <%= render "form", list: @list %>
    </div>
  <% end %>
  ```

### Recommendation Lists — #edit inline from #show

- [ ] **Step 9** — Open `app/views/recommendation_lists/show.html.erb`. Identify the div/section that contains the list title and the "Edit" link. Wrap that section in:
  ```erb
  <%= turbo_frame_tag dom_id(@list) do %>
    ...existing content with edit link...
  <% end %>
  ```
  _(Read the file first to find the exact lines. The frame only needs to wrap the header/title area that contains the Edit link, not the full page.)_

- [ ] **Step 10** — Open `app/views/recommendation_lists/edit.html.erb`. Replace the entire file content with:
  ```erb
  <%= turbo_frame_tag dom_id(@list) do %>
    <div class="w-full max-w-3xl">
      <h1 class="text-2xl font-bold mb-4">Edit List</h1>
      <%= render "form", list: @list %>
    </div>
  <% end %>
  ```

- [ ] **Step 11** — Run tests:
  ```
  bin/rails test
  ```

- [ ] **Step 12** — Commit:
  ```
  git add app/views/books/ app/views/loans/ app/views/recommendation_lists/
  git commit -m "feat(hotwire): inline new/edit forms via turbo frames for books, loans, lists"
  ```

---

## Verification Checklist

Run through these manually after all tracks are done:

| Track | Manual test |
|-------|------------|
| 7a | Delete any book → no crash |
| 7b | Import the mixed wishlist URL → only books imported |
| 2 | Add a book with country `BR`, mark it `:reading` → visit `/map` → BR is amber. Mark `:finished` → turns green. Set a custom color manually → re-mark book → color stays |
| 3 | Map page badges show a number. Profile badges show a number. Click a filled country → panel shows "N book(s) from here" |
| 4 | Click `+` twice → SVG grows. Horizontal scroll appears. `−` shrinks. Reset restores |
| 5 | Resize browser to 375px. Hamburger appears. Tap it → nav links show. All pages scroll without horizontal overflow |
| 6 | Books index: click "New book" → form appears inline. Submit blank title → error inline. Fill → submit → navigate to book show. On book show, click Edit → form appears inline in place of the title |
