import tkinter
from tkinter import messagebox
import random
import csv

CSV_FILE="football_test.csv"

class Quiz():
    def __init__(self, master):
        self.master = master
        
        #クイズのリスト
        self.quiz_list = []

        # 現在表示中のクイズ
        self.now_quiz = None

        # 現在選択中の選択肢番号
        self.choice_value = tkinter.IntVar()

        #変数
        self.a=0
        self.n=0

        self.get_quiz()
        self.screen()
        self.show_quiz()


    def get_quiz(self):
        try:
            f=open(CSV_FILE,  encoding="utf-8_sig" ) 
        except FileNotFoundError:
            return None

        csv_data=csv.reader(f)

        for quiz in csv_data:
            self.quiz_list.append(quiz) 

        f.close()
        self.n=len(self.quiz_list)
        self.n=str(self.n)


    
    def screen(self):
        #フレーム
        self.frame=tkinter.Frame(self.master,width=400,height=400)
        self.frame.pack()
        
        #ボタン
        self.button=tkinter.Button(self.master,text='OK',command=self.check_answer)
        self.button.pack()



    def show_quiz(self):
        #出題していない問題からランダムに出力
        num_quiz=random.randrange(len(self.quiz_list))
        quiz=self.quiz_list[num_quiz]
        
        #問題を表示するラベルの出力
        self.problem=tkinter.Label(self.frame,text=quiz[0])
        self.problem.grid(column=0,row=0,columnspan=4,pady=10)

        #4つの選択肢のの出力
        self.choices=[]
        for i in range(4):
            choice=tkinter.Radiobutton(self.frame,text=quiz[i+1],variable=self.choice_value,value=i)
            choice.grid(row=1,column=i,padx=10,pady=10)

            self.choices.append(choice)

        #出題した問題を削除
        self.quiz_list.remove(quiz)

        #現在出題している問題を格納
        self.now_quiz=quiz


    
    def deletequiz(self):

            # 問題を表示するラベルを削除
            self.problem.destroy()

            # 選択肢を表示するラジオボタンを削除
            for choice in self.choices:
                choice.destroy()


    #答えあわせ
    def check_answer(self):
      　#正解の場合
        if self.choice_value.get()==int(self.now_quiz[5]):
            messagebox.showinfo("result","correct!!")
            self.a=self.a+1
        
        #不正解の場合
        else:
            messagebox.showerror("result","incorrect...\n" + self.now_quiz[6])#解説の表示(後々実装予定)

        self.deletequiz()

        if self.quiz_list:
            self.show_quiz()
        
        else:
            self.a=str(self.a)
            self.endAppli()
            
            
    #前問終了後の処理
    def endAppli(self):
        self.problem=tkinter.Label(self.frame,text="Finish.")
        self.problem.grid(row=0,column=0,padx=10,pady=10)
        self.problem=tkinter.Label(self.frame,text="correct/all" + "=" + self.a + "/" + self.n)
        self.problem.grid(row=1,column=0,padx=10,pady=10)
        self.button.config(command=self.master.destroy)

app = tkinter.Tk()
quiz = Quiz(app)
app.mainloop()
