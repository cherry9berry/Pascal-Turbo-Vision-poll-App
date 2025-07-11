unit Poll;

interface

uses
  App, Objects, Dialogs, Views, Drivers, Menus, MsgBox, StdDlg;

const
  { Команды меню }
  cmNewPoll = 101;
  cmGetStats = 102;
  cmNextQuestion = 103;
  cmPrevQuestion = 104;
  cmResetPoll = 105;
  cmAbout = 106;
  cmExportStats = 107;
  
  { Максимальное количество вопросов }
  MAX_QUESTIONS = 10;
  MAX_ANSWERS = 4;
  
  { Константы диалогов }
  dlgQuestionWindow = 'QuestionDialog';

type
  { Структура для хранения ответа }
  PAnswerData = ^TAnswerData;
  TAnswerData = record
    SelectedAnswer: Word;
    IsAnswered: Boolean;
  end;

  { Массивы для данных }
  TStatsArray = array[1..MAX_QUESTIONS, 1..MAX_ANSWERS] of Integer;
  TSessionArray = array[1..MAX_QUESTIONS] of TAnswerData;
  
  { Структура вопроса }
  PQuestion = ^TQuestion;
  TQuestion = record
    Text: string;
    AnswerA: string;
    AnswerB: string;
    AnswerC: string;
    AnswerD: string;
    AnswerCount: Integer; { Количество вариантов ответов }
  end;
  
  TQuestionArray = array[1..MAX_QUESTIONS] of TQuestion;

  { Окно с вопросами }
  PQuestionWindow = ^TQuestionWindow;
  TQuestionWindow = object(TDialog)
    RadioButtons: PRadioButtons;
    QuestionText: PStaticText;
    QuestionLabel: PLabel;
    ProgressLabel: PLabel;
    NextButton: PButton;
    PrevButton: PButton;
    
    constructor Init;
    procedure UpdateQuestion(QuestionNum: Integer; const Question: TQuestion);
    procedure UpdateProgress(Current, Total: Integer);
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetAnswer: Word;
    procedure SetAnswer(Answer: Word);
    destructor Done; virtual;
  end;

  { Окно статистики }
  PStatsWindow = ^TStatsWindow;
  TStatsWindow = object(TDialog)
    StatsText: PScrollBar;
    
    constructor Init(const Stats: TStatsArray; QuestionCount: Integer; 
                    const Questions: TQuestionArray);
  end;

  { Главное приложение }
  PPollApp = ^TPollApp;
  TPollApp = object(TApplication)
    QuestionWindow: PQuestionWindow;
    CurrentQuestion: Integer;
    TotalQuestions: Integer;
    SessionData: TSessionArray;
    StatsData: TStatsArray;
    Questions: TQuestionArray;
    IsSessionActive: Boolean;
    
    constructor Init;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    
    { Методы для работы с опросом }
    procedure StartNewPoll;
    procedure NextQuestion;
    procedure PrevQuestion;
    procedure FinishPoll;
    procedure ShowStatistics;
    procedure ResetAllData;
    procedure ShowAbout;
    
    { Инициализация данных }
    procedure InitQuestions;
    procedure InitArrays;
    
    { Утилиты }
    procedure SaveAnswer;
    function IsValidSession: Boolean;
    procedure UpdateInterface;
    
    destructor Done; virtual;
  end;

implementation

{$I Questions.inc} { Подключаем файл с вопросами }

{ TQuestionWindow Implementation }

constructor TQuestionWindow.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 70, 20);
  inherited Init(R, 'Система опросов');
  Options := Options or ofCentered;
  
  { Заголовок с номером вопроса }
  R.Assign(2, 2, 30, 3);
  ProgressLabel := New(PLabel, Init(R, 'Вопрос 1 из 1', nil));
  Insert(ProgressLabel);
  
  { Текст вопроса }
  R.Assign(2, 4, 66, 12);
  QuestionText := New(PStaticText, Init(R, ''));
  Insert(QuestionText);
  
  { Радио кнопки для ответов }
  R.Assign(4, 13, 60, 17);
  RadioButtons := New(PRadioButtons, Init(R, 
    NewSItem('~A~', 
    NewSItem('~B~', 
    NewSItem('~C~', 
    NewSItem('~D~', nil))))));
  Insert(RadioButtons);
  
  { Кнопки навигации }
  R.Assign(45, 17, 55, 19);
  PrevButton := New(PButton, Init(R, '<<< ~П~ред', cmPrevQuestion, bfNormal));
  Insert(PrevButton);
  
  R.Assign(56, 17, 66, 19);
  NextButton := New(PButton, Init(R, '~С~лед >>>', cmNextQuestion, bfDefault));
  Insert(NextButton);
  
  { Кнопка отмены }
  R.Assign(2, 17, 12, 19);
  Insert(New(PButton, Init(R, '~О~тмена', cmCancel, bfNormal)));
end;

procedure TQuestionWindow.UpdateQuestion(QuestionNum: Integer; const Question: TQuestion);
var
  QuestionDisplay: string;
begin
  { Формируем текст вопроса с вариантами ответов }
  QuestionDisplay := Question.Text + #13#10#13#10 +
                    'A: ' + Question.AnswerA + #13#10 +
                    'B: ' + Question.AnswerB + #13#10 +
                    'C: ' + Question.AnswerC;
  
  if Question.AnswerCount > 3 then
    QuestionDisplay := QuestionDisplay + #13#10 + 'D: ' + Question.AnswerD;
    
  QuestionText^.SetText(NewStr(QuestionDisplay));
  
  { Обновляем доступность вариантов D }
  if Question.AnswerCount <= 3 then
    RadioButtons^.DisableCommands([3])
  else
    RadioButtons^.EnableCommands([3]);
end;

procedure TQuestionWindow.UpdateProgress(Current, Total: Integer);
var
  ProgressText: string;
begin
  ProgressText := 'Вопрос ' + IntToStr(Current) + ' из ' + IntToStr(Total);
  ProgressLabel^.SetText(NewStr(ProgressText));
  
  { Управление кнопками }
  PrevButton^.SetState(sfDisabled, Current <= 1);
  
  if Current >= Total then
    NextButton^.SetText(NewStr('~З~авершить'))
  else
    NextButton^.SetText(NewStr('~С~лед >>>'));
end;

procedure TQuestionWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNextQuestion, cmPrevQuestion:
        begin
          { Событие будет обработано в главном приложении }
        end;
    end;
  end;
end;

function TQuestionWindow.GetAnswer: Word;
var
  Data: TAnswerData;
begin
  GetData(Data);
  GetAnswer := Data.SelectedAnswer;
end;

procedure TQuestionWindow.SetAnswer(Answer: Word);
var
  Data: TAnswerData;
begin
  Data.SelectedAnswer := Answer;
  Data.IsAnswered := True;
  SetData(Data);
end;

destructor TQuestionWindow.Done;
begin
  inherited Done;
end;

{ TStatsWindow Implementation }

constructor TStatsWindow.Init(const Stats: TStatsArray; QuestionCount: Integer; 
                             const Questions: TQuestionArray);
var
  R: TRect;
  StatsText: string;
  i: Integer;
  ACount, BCount, CCount, DCount, Total: Integer;
begin
  R.Assign(0, 0, 60, 20);
  inherited Init(R, 'Статистика опроса');
  Options := Options or ofCentered;
  
  StatsText := '';
  for i := 1 to QuestionCount do
  begin
    ACount := Stats[i, 1];
    BCount := Stats[i, 2];
    CCount := Stats[i, 3];
    DCount := Stats[i, 4];
    Total := ACount + BCount + CCount + DCount;
    
    StatsText := StatsText + 'Вопрос ' + IntToStr(i) + ':' + #13#10;
    if Total > 0 then
    begin
      StatsText := StatsText + 
        'A: ' + IntToStr(ACount) + ' (' + IntToStr((ACount * 100) div Total) + '%)' + #13#10 +
        'B: ' + IntToStr(BCount) + ' (' + IntToStr((BCount * 100) div Total) + '%)' + #13#10 +
        'C: ' + IntToStr(CCount) + ' (' + IntToStr((CCount * 100) div Total) + '%)';
      
      if Questions[i].AnswerCount > 3 then
        StatsText := StatsText + #13#10 + 
          'D: ' + IntToStr(DCount) + ' (' + IntToStr((DCount * 100) div Total) + '%)';
    end
    else
      StatsText := StatsText + 'Нет ответов';
      
    StatsText := StatsText + #13#10 + 'Всего ответов: ' + IntToStr(Total) + #13#10#13#10;
  end;
  
  R.Assign(2, 2, 56, 16);
  Insert(New(PStaticText, Init(R, NewStr(StatsText))));
  
  R.Assign(24, 17, 34, 19);
  Insert(New(PButton, Init(R, '~З~акрыть', cmOK, bfDefault)));
end;

{ TPollApp Implementation }

constructor TPollApp.Init;
begin
  inherited Init;
  CurrentQuestion := 1;
  TotalQuestions := 0;
  IsSessionActive := False;
  
  InitArrays;
  InitQuestions;
end;

procedure TPollApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~О~прос', hcNoContext, NewMenu(
      NewItem('~Н~овый опрос', 'F2', kbF2, cmNewPoll, hcNoContext,
      NewItem('~С~татистика', 'F3', kbF3, cmGetStats, hcNoContext,
      NewItem('~С~брос данных', 'F4', kbF4, cmResetPoll, hcNoContext,
      NewLine(
      NewItem('~В~ыход', 'Alt+X', kbAltX, cmQuit, hcNoContext,
      nil)))))),
    NewSubMenu('~С~правка', hcNoContext, NewMenu(
      NewItem('~О~ программе', 'F1', kbF1, cmAbout, hcNoContext,
      nil)),
    nil)))));
end;

procedure TPollApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PStatusLine, Init(R,
    NewStatusDef(0, $EFFF,
      NewStatusKey('~F1~ Справка', kbF1, cmAbout,
      NewStatusKey('~F2~ Новый опрос', kbF2, cmNewPoll,
      NewStatusKey('~F3~ Статистика', kbF3, cmGetStats,
      NewStatusKey('~Alt+X~ Выход', kbAltX, cmQuit,
      nil)))),
    nil)));
end;

procedure TPollApp.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmNewPoll:
        begin
          StartNewPoll;
          ClearEvent(Event);
        end;
      cmGetStats:
        begin
          ShowStatistics;
          ClearEvent(Event);
        end;
      cmResetPoll:
        begin
          if MessageBox('Сбросить все данные опроса?', nil, 
                       mfConfirmation or mfYesButton or mfNoButton) = cmYes then
            ResetAllData;
          ClearEvent(Event);
        end;
      cmAbout:
        begin
          ShowAbout;
          ClearEvent(Event);
        end;
      cmNextQuestion:
        begin
          if IsSessionActive then
          begin
            SaveAnswer;
            NextQuestion;
          end;
          ClearEvent(Event);
        end;
      cmPrevQuestion:
        begin
          if IsSessionActive then
          begin
            SaveAnswer;
            PrevQuestion;
          end;
          ClearEvent(Event);
        end;
    end;
  end;
end;

procedure TPollApp.StartNewPoll;
var
  i: Integer;
begin
  { Сброс данных сессии }
  for i := 1 to MAX_QUESTIONS do
  begin
    SessionData[i].SelectedAnswer := 0;
    SessionData[i].IsAnswered := False;
  end;
  
  CurrentQuestion := 1;
  IsSessionActive := True;
  
  { Создание окна вопросов }
  QuestionWindow := New(PQuestionWindow, Init);
  Desktop^.Insert(QuestionWindow);
  
  UpdateInterface;
end;

procedure TPollApp.NextQuestion;
begin
  if not IsValidSession then Exit;
  
  if CurrentQuestion < TotalQuestions then
  begin
    Inc(CurrentQuestion);
    UpdateInterface;
  end
  else
  begin
    { Завершение опроса }
    FinishPoll;
  end;
end;

procedure TPollApp.PrevQuestion;
begin
  if not IsValidSession then Exit;
  
  if CurrentQuestion > 1 then
  begin
    Dec(CurrentQuestion);
    UpdateInterface;
  end;
end;

procedure TPollApp.FinishPoll;
var
  i: Integer;
  UnansweredCount: Integer;
begin
  if not IsValidSession then Exit;
  
  { Проверка на неотвеченные вопросы }
  UnansweredCount := 0;
  for i := 1 to TotalQuestions do
    if not SessionData[i].IsAnswered then
      Inc(UnansweredCount);
  
  if UnansweredCount > 0 then
  begin
    if MessageBox('Остались неотвеченные вопросы (' + IntToStr(UnansweredCount) + 
                 '). Завершить опрос?', nil, 
                 mfConfirmation or mfYesButton or mfNoButton) <> cmYes then
      Exit;
  end;
  
  { Сохранение результатов в статистику }
  for i := 1 to TotalQuestions do
  begin
    if SessionData[i].IsAnswered and (SessionData[i].SelectedAnswer > 0) then
      Inc(StatsData[i, SessionData[i].SelectedAnswer]);
  end;
  
  IsSessionActive := False;
  QuestionWindow^.Close;
  
  MessageBox('Опрос завершен! Ваши ответы сохранены.', nil, 
            mfInformation or mfOKButton);
end;

procedure TPollApp.ShowStatistics;
var
  StatsWindow: PStatsWindow;
begin
  if TotalQuestions = 0 then
  begin
    MessageBox('Нет данных для отображения статистики.', nil, 
              mfWarning or mfOKButton);
    Exit;
  end;
  
  StatsWindow := New(PStatsWindow, Init(StatsData, TotalQuestions, Questions));
  Desktop^.ExecView(StatsWindow);
  Dispose(StatsWindow, Done);
end;

procedure TPollApp.ResetAllData;
begin
  InitArrays;
  IsSessionActive := False;
  CurrentQuestion := 1;
  
  if QuestionWindow <> nil then
    QuestionWindow^.Close;
    
  MessageBox('Все данные сброшены.', nil, mfInformation or mfOKButton);
end;

procedure TPollApp.ShowAbout;
begin
  MessageBox(#3'Система опросов v2.0'#13#10#13#10 +
            'Профессиональная система для проведения опросов'#13#10 +
            'с расширенной статистикой и удобным интерфейсом.'#13#10#13#10 +
            'Borland Pascal 7.0 + Turbo Vision 2.0', nil, 
            mfInformation or mfOKButton);
end;

procedure TPollApp.InitQuestions;
begin
  { Вопрос 1 }
  Questions[1].Text := 'Кто был первым президентом США?';
  Questions[1].AnswerA := 'Джордж Вашингтон';
  Questions[1].AnswerB := 'Авраам Линкольн';
  Questions[1].AnswerC := 'Джон Кеннеди';
  Questions[1].AnswerD := 'Томас Джефферсон';
  Questions[1].AnswerCount := 4;
  
  { Вопрос 2 }
  Questions[2].Text := 'В каком году началась Французская революция?';
  Questions[2].AnswerA := '1789';
  Questions[2].AnswerB := '1812';
  Questions[2].AnswerC := '1917';
  Questions[2].AnswerD := '1776';
  Questions[2].AnswerCount := 4;
  
  { Вопрос 3 }
  Questions[3].Text := 'В какой стране родился Адольф Гитлер?';
  Questions[3].AnswerA := 'Австрия';
  Questions[3].AnswerB := 'Германия';
  Questions[3].AnswerC := 'Италия';
  Questions[3].AnswerD := 'Швейцария';
  Questions[3].AnswerCount := 4;
  
  { Вопрос 4 }
  Questions[4].Text := 'Какая планета ближайшая к Солнцу?';
  Questions[4].AnswerA := 'Венера';
  Questions[4].AnswerB := 'Меркурий';
  Questions[4].AnswerC := 'Марс';
  Questions[4].AnswerD := 'Земля';
  Questions[4].AnswerCount := 4;
  
  { Вопрос 5 }
  Questions[5].Text := 'Кто написал роман "Война и мир"?';
  Questions[5].AnswerA := 'Федор Достоевский';
  Questions[5].AnswerB := 'Лев Толстой';
  Questions[5].AnswerC := 'Антон Чехов';
  Questions[5].AnswerCount := 3;
  
  TotalQuestions := 5;
end;

procedure TPollApp.InitArrays;
var
  i, j: Integer;
begin
  { Инициализация массива статистики }
  for i := 1 to MAX_QUESTIONS do
    for j := 1 to MAX_ANSWERS do
      StatsData[i, j] := 0;
      
  { Инициализация массива сессии }
  for i := 1 to MAX_QUESTIONS do
  begin
    SessionData[i].SelectedAnswer := 0;
    SessionData[i].IsAnswered := False;
  end;
end;

procedure TPollApp.SaveAnswer;
var
  Answer: Word;
begin
  if not IsValidSession then Exit;
  
  Answer := QuestionWindow^.GetAnswer;
  if Answer > 0 then
  begin
    SessionData[CurrentQuestion].SelectedAnswer := Answer;
    SessionData[CurrentQuestion].IsAnswered := True;
  end;
end;

function TPollApp.IsValidSession: Boolean;
begin
  IsValidSession := IsSessionActive and (QuestionWindow <> nil) and 
                   (CurrentQuestion >= 1) and (CurrentQuestion <= TotalQuestions);
end;

procedure TPollApp.UpdateInterface;
begin
  if not IsValidSession then Exit;
  
  QuestionWindow^.UpdateQuestion(CurrentQuestion, Questions[CurrentQuestion]);
  QuestionWindow^.UpdateProgress(CurrentQuestion, TotalQuestions);
  
  { Восстановление предыдущего ответа }
  if SessionData[CurrentQuestion].IsAnswered then
    QuestionWindow^.SetAnswer(SessionData[CurrentQuestion].SelectedAnswer);
end;

destructor TPollApp.Done;
begin
  inherited Done;
end;

{ Вспомогательная функция для конвертации числа в строку }
function IntToStr(Value: Integer): string;
var
  S: string;
begin
  Str(Value, S);
  IntToStr := S;
end;

end.
