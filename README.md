# ClassiFy 🔍

ClassiFy is a Flutter-based image classification app that uses machine learning to identify objects in images with confidence scores. This is a personal project I developed to bring an idea I had in mind for a few months to life.

## Features 🌟

- Classifies images using a TensorFlow Lite pre-trained MobileNet model.
- Displays the top three predictions with confidence scores.
- Simple and intuitive UI.
- Provides details about the app functionality via an info icon.
- Added some fake latency to enhance the user experience.

## How It Works 🔬

1. Pick an image from your device.
2. The app processes the image using the MobileNet model.
3. Get results showing the most probable classification along with confidence percentages.

![App in Action](assets/app-screen.gif)

## Technologies Used 🤖

- **Flutter**: To build the app.
- **TensorFlow Lite**: For on-device machine learning.

## Model Details 🔸

The app uses the MobileNet v1 model:
- Model: [MobileNet v1 1.0 224](https://github.com/emgucv/models/blob/master/mobilenet_v1_1.0_224_float_2017_11_08/mobilenet_v1_1.0_224.tflite)

> **Note:** I couldn't find the first source of the model. If I locate it, I will update this information.

## Getting Started 🚀

### Prerequisites

- Flutter SDK installed on your machine.
- An emulator or physical device to run the app.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/dinithmaleesha/flutter-image-classification.git
   cd flutter-image-classification
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Building the APK

To build the APK:
```bash
flutter build apk --release
```

The generated APK will be available in the `build/app/outputs/flutter-apk/` directory.

## Credits 🌟

- **Model**: MobileNet v1 from TensorFlow Lite.
- **Icons**: [Flaticon](https://www.flaticon.com).

## Future Improvements 🚒

- Enhance the UI with more interactive elements.
- Add support for additional models and image processing features.
- Improve result explanations for better user understanding.

## Contributions 🤝

Contributions are welcome! Feel free to fork this repository, make changes, and submit a pull request.

---

Developed with ❤️ by Dinith Maleesha.
