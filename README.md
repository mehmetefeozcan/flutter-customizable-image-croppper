## Flutter Customizable Image Croppper

### Why You Use This Package ?

- The shape of the cropper widget is not fixed, instead you can make it any way you want.
- This allows you to crop the image wherever you want, however you want.

### Features

- It helps you crop the picture as you want.
- Multi image type support.

### Usage

---

First create a sample the CropController.

```dart
CropController cropController =  CropController(
  imageType: ImageType.url,
  image: "https://picsum.photos/id/234/200/200",
);
```

Second set the created sample controller in the 'CustomizableImageCropper' widget properties.

```dart
CustomizableImageCropper(controller: cropController),
```

After this steps, call 'crop()' method the cropController's in the your wanna click or tap event method.

```dart

ElevatedButton(
  child: Text("Save"),
  onPressed: () async {
    await cropController.crop();
  },
),

```

Finally find the croped image in the 'cropedImageFile' properties in the cropController's

```dart

ElevatedButton(
  child: Text("Save"),
  onPressed: () async {
    await cropController.crop();
    print(cropController.cropedImageFile);
  },
),

```
