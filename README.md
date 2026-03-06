# Laptop Harbor – E-Commerce Mobile Application

Laptop Harbor is a full-stack e-commerce mobile application developed using **Flutter and Firebase**. The app allows users to browse laptops and accessories, add items to their cart, place orders, and track order status.

The platform also includes an **admin management system** where administrators can manage products, customer information, orders, and billing details.

This project was created as a practice project to build a real-world **mobile e-commerce application with backend integration**.

---

## 📱 Project Overview

Laptop Harbor is designed to simulate a real online electronics store where customers can explore and purchase laptops and accessories through a mobile application.

The system includes:

* Customer-facing mobile application
* Backend services powered by Firebase
* Admin panel for managing store operations

---

## 🚀 Key Features

### Customer Side (Mobile App)

* Browse available **laptops and accessories**
* View detailed product information
* Add products to cart
* Manage shopping cart
* Place orders
* Track order status
* View billing and order information
* Secure user authentication
* Simple and user-friendly interface

---

### Admin Panel

The system includes an **admin dashboard** that allows administrators to manage the entire store.

Admin capabilities include:

* Manage products (laptops & accessories)
* View and manage customer orders
* Access customer information
* Track payments and billing details
* Update order status
* Manage store inventory

---

## 🛠️ Technologies Used

### Mobile Application

* **Flutter** – Cross-platform mobile app framework
* **Dart** – Programming language used by Flutter

### Backend & Database

* **Firebase** – Backend services
* **Firebase Firestore / Realtime Database** – Data storage
* **Firebase Authentication** – User authentication

### Development Tools

* **Git & GitHub** – Version control
* **Android Studio / VS Code** – Development environment

---

## 📂 Project Structure

The project includes the following main components:

* **Mobile Application (Flutter)**
* **Firebase Backend Services**
* **Admin Management Panel**

These components work together to simulate a complete e-commerce system.

---

## 📦 Installation (Run Locally)

Follow these steps to run the project locally.

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/zohaib-uddin/your-repository-link.git
```

---

### 2️⃣ Navigate to the Project Folder

```bash
cd laptop-harbor
```

---

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 4️⃣ Run the Application

```bash
flutter run
```

---

## ⚙️ Firebase Configuration

To run the project properly, you must configure Firebase:

1. Create a project in **Firebase Console**
2. Connect the Flutter application
3. Add the Firebase configuration files:

Android:

```
google-services.json
```

iOS:

```
GoogleService-Info.plist
```

4. Enable Firebase services such as:

* Authentication
* Firestore Database
* Storage (if required)

---

## 📌 Project Purpose

This project was developed as a **full-stack mobile application practice project** to demonstrate how an e-commerce platform can be built using **Flutter for the frontend and Firebase for backend services**.

It showcases core e-commerce features such as cart management, order processing, and admin-level management functionality.

---

## 🔐 Admin Panel Access (Development)

The project includes a **separate Admin Panel** for managing orders, customers, and billing.
To access the admin panel in the Flutter app:

1. Open `lib/main.dart`.
2. You will see these lines:

```dart
home: const SplashScreen(),
// home: const AdminLoginScreen(),
```

* By default, the **SplashScreen** is uncommented and the **user frontend** will launch.
* To run the **Admin Panel**, comment the `SplashScreen` line and uncomment the `AdminLoginScreen` line:

```dart
// home: const SplashScreen(),
home: const AdminLoginScreen(),
```

3. Run the app. You will see the **Admin Login Screen**.

### Admin Credentials

* **Email:** admin@gmail.com
* **Password:** admin123

This allows you to login and manage all backend data (orders, customers, products, billing, etc.) via the admin interface.

---

## ⚠️ Note

This project is **not currently deployed or hosted**.
The repository contains the **complete source code** for development and educational purposes.

---

## 👨‍💻 Developer

Developed by **Zohaib Uddin**

GitHub:
https://github.com/zohaib-uddin

---

## 📄 License

This project is shared for educational and portfolio purposes.
