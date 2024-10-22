unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

const
  SnakeSize = 20;  // Ukuran setiap segmen ular
  InitialSnakeLength = 3;  // Panjang awal ular
  GameAreaSize = 400;  // Ukuran area permainan (kotak persegi)
  FoodSize = 15;  // Ukuran makanan

type
  // Deklarasi tipe arah ular
  TSnakeDirection = (sdUp, sdDown, sdLeft, sdRight);

  { TForm1 }

  TForm1 = class(TForm)
    BtnUp: TButton;
    BtnDown: TButton;
    BtnLeft: TButton;
    BtnRight: TButton;
    BtnExit: TButton;
    BtnStart: TButton;
    BtnStop: TButton;  // Tombol untuk pause
    BtnUlti: TButton;
    Timer1: TTimer;
    procedure BtnDownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure BtnExitClick(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure BtnLeftClick(Sender: TObject);
    procedure BtnRightClick(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);  // Untuk pause dan resume
    procedure BtnUltiClick(Sender: TObject);  // Untuk menggambar I LOVE YOU
    procedure BtnUpKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);  // Untuk menggambar ulang form
  private
    Snake: array of TPoint;  // Untuk menyimpan posisi ular
    SnakeDirection: TSnakeDirection;  // Arah ular
    GamePaused: Boolean;  // Status apakah game sedang pause
    ShowingMessage: Boolean;  // Status apakah sedang menampilkan pesan
    FoodPosition: TPoint;  // Posisi makanan
    procedure MoveSnake;  // Prosedur untuk menggerakkan ular
    procedure ResetGame;  // Prosedur untuk mereset permainan
    procedure DrawMessage;  // Prosedur untuk menggambar pesan
    function CheckCollisionWithFood: Boolean;  // Fungsi untuk cek tabrakan dengan makanan
    procedure PlaceFood;  // Prosedur untuk menempatkan makanan di area permainan
  end;

var
  Form1: TForm1;
  GameAreaRect: TRect;  // Area permainan (batas kotak)

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Inisialisasi permainan saat form dibuat
  Timer1.Interval := 200;  // Kecepatan ular
  Timer1.Enabled := False;  // Timer tidak aktif saat awal
  GamePaused := False;  // Awalnya game tidak dalam status pause
  ShowingMessage := False;  // Awalnya tidak menampilkan pesan
  GameAreaRect := Rect((ClientWidth - GameAreaSize) div 2, (ClientHeight - GameAreaSize) div 2,
                       (ClientWidth + GameAreaSize) div 2, (ClientHeight + GameAreaSize) div 2);
  ResetGame;  // Inisialisasi ulang permainan
end;

procedure TForm1.ResetGame;
begin
  // Reset panjang dan posisi ular
  SetLength(Snake, InitialSnakeLength);  // Atur panjang awal ular
  Snake[0].X := (ClientWidth div 2) - (SnakeSize div 2);  // Posisi awal kepala ular (di dalam kotak)
  Snake[0].Y := (ClientHeight div 2) - (SnakeSize div 2);   // Posisi awal kepala ular (di dalam kotak)

  // Atur segmen-segmen tubuh ular di belakang kepala
  Snake[1].X := Snake[0].X - SnakeSize;
  Snake[1].Y := Snake[0].Y;
  Snake[2].X := Snake[1].X - SnakeSize;
  Snake[2].Y := Snake[1].Y;

  SnakeDirection := sdRight;  // Arah awal ular
  PlaceFood;  // Tempatkan makanan
  Invalidate;  // Render ulang tampilan form
end;

procedure TForm1.PlaceFood;
begin
  // Tempatkan makanan di posisi acak dalam area permainan
  FoodPosition.X := Random(GameAreaSize div SnakeSize) * SnakeSize + GameAreaRect.Left;
  FoodPosition.Y := Random(GameAreaSize div SnakeSize) * SnakeSize + GameAreaRect.Top;
end;

procedure TForm1.MoveSnake;
var
  i: Integer;
  NextPos: TPoint;
begin
  // Gerakkan setiap bagian tubuh mengikuti kepala
  for i := High(Snake) downto 1 do
    Snake[i] := Snake[i-1];

  // Tentukan posisi berikutnya berdasarkan arah
  NextPos := Snake[0];
  case SnakeDirection of
    sdUp: Dec(NextPos.Y, SnakeSize);
    sdDown: Inc(NextPos.Y, SnakeSize);
    sdLeft: Dec(NextPos.X, SnakeSize);
    sdRight: Inc(NextPos.X, SnakeSize);
  end;

  // Update posisi kepala ular
  Snake[0] := NextPos;

  // Cek tabrakan dengan makanan
  if CheckCollisionWithFood then
  begin
    // Tambah panjang ular
    SetLength(Snake, Length(Snake) + 1);
    Snake[High(Snake)] := Snake[High(Snake) - 1];  // Atur segmen baru ke posisi terakhir
    PlaceFood;  // Tempatkan makanan baru
  end;

  Invalidate;  // Render ulang tampilan ular
end;

function TForm1.CheckCollisionWithFood: Boolean;
begin
  // Memeriksa apakah kepala ular bertabrakan dengan makanan
  Result := (Snake[0].X < FoodPosition.X + FoodSize) and
            (Snake[0].X + SnakeSize > FoodPosition.X) and
            (Snake[0].Y < FoodPosition.Y + FoodSize) and
            (Snake[0].Y + SnakeSize > FoodPosition.Y);
end;
  //untuk mengarahkan arah ular
procedure TForm1.BtnUpClick(Sender: TObject);
begin
  if SnakeDirection <> sdDown then
    SnakeDirection := sdUp;
end;

procedure TForm1.BtnDownClick(Sender: TObject);
begin
  if SnakeDirection <> sdUp then
    SnakeDirection := sdDown;
end;

procedure TForm1.BtnLeftClick(Sender: TObject);
begin
  if SnakeDirection <> sdRight then
    SnakeDirection := sdLeft;
end;

procedure TForm1.BtnRightClick(Sender: TObject);
begin
  if SnakeDirection <> sdLeft then
    SnakeDirection := sdRight;
end;

procedure TForm1.BtnStopClick(Sender: TObject);
begin
  // Logika untuk pause atau resume permainan
  if GamePaused then
  begin
    Timer1.Enabled := True;  // Resume permainan
    BtnStop.Caption := 'Pause';  // Ubah teks tombol
    GamePaused := False;
  end
  else
  begin
    Timer1.Enabled := False;  // Pause permainan
    BtnStop.Caption := 'Resume';  // Ubah teks tombol
    GamePaused := True;
  end;
end;

procedure TForm1.BtnUltiClick(Sender: TObject);
begin
  Timer1.Enabled := False;  // Hentikan pergerakan ular
  ShowingMessage := True;  // Set status untuk menggambar pesan
  Invalidate;  // Render ulang form untuk menampilkan pesan
end;

procedure TForm1.BtnUpKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TForm1.BtnExitClick(Sender: TObject);
begin
  Application.Terminate;  // Keluar dari aplikasi saat tombol Exit diklik
end;

procedure TForm1.BtnDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TForm1.BtnStartClick(Sender: TObject);
begin
  ResetGame;  // Reset posisi ular
  Timer1.Enabled := True;  // Aktifkan timer untuk memulai permainan
  BtnStop.Caption := 'Pause';  // Pastikan teks tombol diatur menjadi 'Pause'
  GamePaused := False;  // Pastikan game tidak dalam status pause
  ShowingMessage := False;  // Tidak menampilkan pesan saat mulai
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if not GamePaused then
    MoveSnake;  // Panggil prosedur untuk menggerakkan ular
end;

procedure TForm1.FormPaint(Sender: TObject);
var
  i: Integer;
begin
  if ShowingMessage then
  begin
    DrawMessage;  // Jika sedang menampilkan pesan, gambar pesan
    Exit;
  end;

  // Menggambar area permainan (batas kotak)
  //Canvas.Pen.Color := clBlack;
  //Canvas.Pen.Width := 3;
  //Canvas.Brush.Style := bsClear;  // Pastikan kotak tidak diisi

  // Menggambar ular
  Canvas.Brush.Color := clGreen;
  for i := Low(Snake) to High(Snake) do
    Canvas.FillRect(Snake[i].X, Snake[i].Y, Snake[i].X + SnakeSize, Snake[i].Y + SnakeSize);

  // Menggambar makanan
  Canvas.Brush.Color := clRed;  // Warna makanan
  Canvas.Ellipse(FoodPosition.X, FoodPosition.Y, FoodPosition.X + FoodSize, FoodPosition.Y + FoodSize); // Menggambar lingkaran untuk makanan
end;
//menampilkan pesan
procedure TForm1.DrawMessage;
begin
  Canvas.Brush.Color := clWhite;
  Canvas.Font.Size := 30;
  Canvas.TextOut((ClientWidth div 2) - 100, ClientHeight div 2, 'TIDAK ADA JURUS');
end;

end.

