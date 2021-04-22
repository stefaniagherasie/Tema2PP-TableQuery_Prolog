# Tema2PP-TableQuery_Prolog
[Tema2 Paradigme de Programare (2019-2020, seria CB)] 

Tema presupune interogarea unor tabele in Prolog si efectuarea de operatii de Select, Filter, Join etc.



#### RULARE
```shell
python3 check_test.py [--hwfile <file_name>.pl]
                      [--testname <test_name>]
                      [--reffile <reffile_path>]
                      [--testsetname <test_set_name>]
```
                 
By default, se ruleaza toate testele, iar numele fisierului cu implementarile se considera implicit
ca fiind `main.pl`. Fisierul de referinta trebuie specificat in cazul in care se doreste rularea unui
singur test. De asemenea, se poate opta si pentru rularea unui anume set de teste (seturile sunt
impartite per query).
