# Pulse: Social Finance Hub Transformation

## Goal
Transform the "Community" tab into **"Pulse"** - a high-engagement social finance feed where communication meets transaction. Users can't just talk; they can *act* financially (Split, Chip In, Bet, Pay).

## 1. Branding & Structure
- **Name**: "Threads" -> **"Pulse"**.
- **Layout**:
    - **Header**: Glassmorphic, sticky, with filter chips (All, Requests, Wins, News).
    - **FAB**: "Compose Pulse" button (Floating Action Button) with a speed dial for context (e.g., "Post Request", "Share Win").
    - **Navigation**: Deep linking to post details for comments/replies.

## 2. The "Pulse" Card (Post UI)
A rich card supporting standard text/media PLUS a **"Financial Action Deck"**:

### Core Interactive Features (The "Social Money" Layer)
We will implement 10+ action types as "Smart Chips" or an "Action Bar" on every post.

1.  **💸 Split**: "Split this bill/expense". Opens a user picker to divide the amount.
2.  **🥣 Chip In**: "Contribute to this". For crowdfunding a goal or group gift.
3.  **🆚 Compare**: "Which is better?". A voting poll for financial decisions (e.g., "Buy vs Rent").
4.  **⚡ Send**: Direct P2P transfer contextually linked to the post.
5.  **🤝 Vouch**: Social credit score. "I trust this person's advice".
6.  **🎱 Bet**: Prediction market. "I bet $50 $TSLA hits $300".
7.  **🧾 Invoice**: "Here's the receipt". Attach a structured debt request.
8.  **🎁 Gift**: Send value as a thank you.
9.  **📡 Signal**: "Copy my trade". For investment posts.
10. **🏆 Challenge**: "Save \$50 this week". Users join a timed goal.
11. **🚨 Alert**: "Price drop detected". automated or user-generated warning.
12. **💡 Request**: "I need \$20 until Friday". Structured loan request.

## 3. Interaction Architecture
- **Comments/Replies**: A specialized `PulseDetailScreen` with threaded comments.
- **Compose Modal**: A premium bottom sheet that allows attaching "Financial Objects" (a bill, a request, a prediction) to the text.

## Implementation Steps

### Step 1: Core UI Overhaul
- [ ] Rename Screen to `PulseScreen`.
- [ ] Implement `PulseAppbar` with filters.
- [ ] Implement `PulseFloatingActionButton` (The "Compose" button).
- [ ] Create `ComposePulseModal` with "Attachment" options for the 12 features.

### Step 2: The "Smart Post" Card
- [ ] Create `PulsePostCard` widget.
- [ ] Implement the `ActionDeck` (Horizontal scrollable list of actionable buttons: Split, Chip In, etc.).
- [ ] Connect "Like" (Heart), "Comment" (Bubble), "Share" (Arrow).

### Step 3: Detail View
- [ ] Create `PulseDetailScreen`.
- [ ] Implement Firestore "Comments" sub-collection logic.

### Step 4: Logic Stubs
- [ ] Wire up the "Split", "Chip In", "Send" buttons to show a beautiful "Feature Preview" bottom sheet (since full backend logic for splitting is a separate epic). The *User Experience* will be fully visible.
