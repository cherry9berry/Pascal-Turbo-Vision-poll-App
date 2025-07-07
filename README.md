# Borland Pascal Turbo Vision

Borland Pascal 7.0 & Turbo Vision 2.0
Uses messageBox, RadioButtons, TDialog, Tapplication and other.

User interface

![alt text](https://i.ibb.co/MSLTyJB/03-06-2024-123103.jpg)
![alt text](https://i.ibb.co/30Qs8FH/20-06-2024-194049.jpg)
![alt text](https://i.ibb.co/YjVLKsp/20-06-2024-194144.jpg)
## Below is chat gpt desription...
The code is written in Pascal and seems to be a part of a questionnaire or polling application. It consists of various units, types, methods, and variables. Here's a detailed description of the code:

### Interface Section

In the interface section, the code includes various units like app, objects, dialogs, views, drivers, menus, and MsgBox, which are utilized in the program.

It also defines several constants like `cmNewpoll`, `cmGetstats`, `cmPass`, and `num`. The `num` constant is used to specify the count of questions.

Several custom types are defined including `POrder`, `TOrder`, `warehouse`, `quests`, and `session`. These types are used to store information related to questions, answers, and user responses.

The code also defines a few variables like `Body`, `questionIndex`, and `tempstr`, which are used for various operations within the program.

### Type Definitions

The type `TOrder` is a record with a single field, `answer`, which is an integer. This is used for keeping radio button answers.

### Implementation Section

The implementation section includes the definitions for methods and procedures used in the application.

### TListWindow

The `TListWindow` object is a child of `TDialog` and is responsible for displaying the questions and options to users. It contains a method `NextQuestion` for displaying the next question and its options.

### TPollApp

The `TPollApp` object is a child of `TApplication` and is the main application object. It includes methods like `Init`, `InitMenuBar`, `PageSwitch`, `HandleEvent`, `Newpoll`, `StatsResult`, `InitArray`, `InitQuestions`, and `Done` for various functionalities of the polling application.

### Procedures and Methods

Several procedures and methods are defined for handling events, initializing the application, displaying questions, and gathering statistics.

### Initialize and User Interaction

The `Init` method initializes the application, sets the initial question index, and other necessary initializations. The `InitMenuBar` method sets up the menu bar for the application. `Newpoll` method starts a new poll and `PageSwitch` method handles switching between different questions.

### Handling Events

The `HandleEvent` method is responsible for handling user events such as starting a new poll, navigating through questions, exiting the application, and requesting statistics.

### Polling and Statistics

Methods like `InitArray` and `InitQuestions` are used for initializing arrays and question texts. The `StatsResult` method is used to display statistics of the poll.

### Conclusion

The code seems to be a part of a polling application written in Pascal that allows users to answer multiple-choice questions and gathers statistics based on their responses. The application consists of dialog windows to display questions, radio buttons for selecting answers, and methods for handling events and gathering statistics.

The code appears to be a part of a larger application that is designed to interact with users, present questions, store and process answers, and display statistical information.
