rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    // Users Collection
    match /users/{userId} {
      allow read, write: if isSignedIn();
    }

    // Bee Boxes Collection
    match /bee_boxes/{beeBoxId} {
      allow read, write: if isSignedIn();
    }

    // Payments Collection
    match /payments/{paymentId} {
      allow read, write: if isSignedIn();
    }

    // Default: deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}