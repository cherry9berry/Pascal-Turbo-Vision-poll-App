# Poll System

**Borland Pascal 7.0 + Turbo Vision 2.0**

![Main Menu](https://i.ibb.co/MSLTyJB/03-06-2024-123103.jpg)
![Question Window](https://i.ibb.co/30Qs8FH/20-06-2024-194049.jpg)
![Statistics](https://i.ibb.co/YjVLKsp/20-06-2024-194144.jpg)

---

## English

### Description
A professional polling system with advanced statistics and a user-friendly interface. The application allows creating surveys, collecting user responses, and analyzing results in real-time.

### Features
* Question navigation (forward/backward)
* Progress indicator
* Answer modification before completion
* Extended statistics with percentages
* Support for up to 10 questions with 3-4 answer options
* Data reset and session management
* Full menu system with hotkeys

### Technical Details
Uses Turbo Vision components for the graphical user interface. Key components include: **TApplication, TDialog, PRadioButtons, PStaticText, PButton, MessageBox, PLabel, PScrollBar**. The code is organized with modular architecture and clear separation of logic and interface.

### Data Structures
* **`TAnswerData`**: Records the selected answer and whether a question has been answered.
* **`TStatsArray`**: Stores statistical data for each answer option per question (e.g., `array[1..MAX_QUESTIONS, 1..MAX_ANSWERS] of Integer`).
* **`TSessionArray`**: Stores user's answers for the current session (e.g., `array[1..MAX_QUESTIONS] of TAnswerData`).
* **`TQuestion`**: Defines a question, including its text, up to 4 answer options, and the count of valid answers.
* **`TQuestionArray`**: An array storing all questions (e.g., `array[1..MAX_QUESTIONS] of TQuestion`).

### Project Structure
* `MAIN.pas` - main launch module
* `POLL.pas` - core application logic and interface

### Compilation
Requires Borland Pascal 7.0 with the Turbo Vision 2.0 library.

---

## Русский

### Описание
Приложение для проведения опросов с расширенной статистикой и удобным интерфейсом. Приложение позволяет создавать опросы, собирать ответы пользователей и анализировать результаты в реальном времени.

### Функциональность
* Система навигации между вопросами (вперед/назад)
* Индикатор прогресса прохождения опроса
* Возможность изменения ответов до завершения
* Расширенная статистика с процентным соотношением
* Поддержка до 10 вопросов с 3-4 вариантами ответов
* Сброс данных и управление сессиями
* Полноценная система меню с горячими клавишами

### Технические детали
Использует компоненты Turbo Vision для графического интерфейса пользователя. Основные компоненты включают: **TApplication, TDialog, PRadioButtons, PStaticText, PButton, MessageBox, PLabel, PScrollBar**. Код организован по модульному принципу с четким разделением логики и интерфейса.

### Структуры данных
* **`TAnswerData`**: Записывает выбранный ответ и статус отвеченности вопроса.
* **`TStatsArray`**: Хранит статистические данные для каждого варианта ответа по каждому вопросу (например, `array[1..MAX_QUESTIONS, 1..MAX_ANSWERS] of Integer`).
* **`TSessionArray`**: Хранит ответы пользователя для текущей сессии (например, `array[1..MAX_QUESTIONS] of TAnswerData`).
* **`TQuestion`**: Определяет вопрос, включая его текст, до 4 вариантов ответов и количество действительных вариантов ответов.
* **`TQuestionArray`**: Массив, хранящий все вопросы (например, `array[1..MAX_QUESTIONS] of TQuestion`).

### Структура проекта
* `MAIN.pas` - главный модуль запуска
* `POLL.pas` - основная логика приложения и интерфейс

### Компиляция
Требуется Borland Pascal 7.0 с подключенной библиотекой Turbo Vision 2.0.

---
*Coursework in Programming, Bauman Moscow State Technical University*
*Курсовая работа МГТУ им. Н.Э. Баумана*
