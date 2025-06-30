

# 🧠 MindNest – Your Personal AI Wellness Space

MindNest is a gentle, interactive journaling app that helps users check in with their emotions through playful mood tracking and emotionally intelligent prompts.

![MindNest Screenshot](https://your-screenshot-link.com) <!-- Replace with your actual image link -->

---

## 🌟 Inspiration

We’ve all had days when we feel overwhelmed, disconnected, or unsure about our emotional state. Mental health support doesn't always need to be clinical — it can be gentle, reflective, and personal. MindNest was built with the intention to create a non-intrusive, emotionally intelligent space where users can explore how they feel, one mood at a time.

---

## 💡 What It Does

MindNest empowers users to:

- 🎡 Spin a **Mood Wheel** to select how they're feeling
- ✍️ Respond to contextual **emotion-based prompts**
- 📘 Record their thoughts in a **mood-tagged journal**
- 🚨 Trigger **SOS support** with music or friend outreach when repeated negative patterns are detected
- ⏰ Get **gentle nudges** when they've been inactive for a while
- 📊 See a **mood frequency chart** (emoji-based)

---

## 🛠️ How We Built It

Built using Flutter & Dart:

- `flutter_fortune_wheel`: for spinning the mood wheel
- `shared_preferences`: to save journal entries locally
- `intl`: for timestamp formatting
- `url_launcher`: for SOS support (calming music, etc.)
- `flutter_chart`: (optional) to show emoji mood trends

---

## 🚧 Challenges We Ran Into

- 🧠 Designing SOS detection logic that feels helpful, not intrusive
- 😊 Emoji-based mood tracking (for both UI and logic)
- 🔁 Smooth state management between mood selection, journaling, and storage
- ⚖️ Balancing emotional tone — supportive, never judgmental

---

## ✅ Accomplishments We’re Proud Of

- Built an **emotion-first UX** with interactive elements
- Added real support via **SOS detection & resources**
- Designed a clean, friendly interface that feels like a companion
- Kept it **offline-first** for privacy and accessibility

---

## 📚 What We Learned

- Using Flutter packages to create engaging UI
- Handling and storing mood-based data
- Creating AI-inspired support mechanisms without full NLP
- The importance of empathy in wellness tech

---

## 🔮 What’s Next

- 📈 Mood analytics dashboard (calendar + emoji trend charts)
- ☁️ Cloud sync for cross-device support
- 🤖 AI journaling assistant with reflective feedback
- 🧘 Breathing exercises and mindfulness mini-games
- 🔔 Daily mood check-in reminders

---

## 🚀 Getting Started

```bash
git clone https://github.com/your-username/MindNest.git
cd MindNest
flutter pub get
flutter run
