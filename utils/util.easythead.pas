unit Util.EasyThead;

// Thread fácil para uso em forms e classes
// Aldo Marcio Soares - ams2kg@gmail.com - 05/2025

{
  procedure Form1.Button1;
  var
    et: TEasyThread;
  begin
    et := TEasyThread.Create(True);
    et.ExecuteProcedure  := @ProcExecuteThread; // Form1.ProcExecuteThread
    et.CallBackProcedure := @ProcReturn;        // Form1.ProcReturn
    et.Start;
  end;
}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  { TEasyThread }

  TEasyThread = class(TThread)
    // procedure a ser executada
    ExecuteProcedure: procedure of object;
    // procedure de retorno
    CallBackProcedure: procedure of object;
    protected
      procedure Execute; override;
    private
      procedure ChamaCallBack;
    public
      constructor Create(CreateSuspended: boolean);
  end;

implementation

{ TEasyThread }

constructor TEasyThread.Create(CreateSuspended: boolean);
// use o .Start para iniciar a thead e não precisa usar o .Free
begin
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);
end;

procedure TEasyThread.Execute;
// executa o código em segundo plano
begin
  // chama a procedure onde o código em background será executado
  ExecuteProcedure;

  // chama o callback que irá consumir os dados processados
  Synchronize(@ChamaCallBack);
end;

procedure TEasyThread.ChamaCallBack;
// exibe os dados no form
begin
  // retorna o controle para a procedure onde o resultado será consumido
  CallBackProcedure;
end;

end.

