# Рекалибровка стереопары на основе ошибки репроекции

В репозитории представлена реализация рекалибровки стереопары (пары камер) с использованием только ошибки репроекции.

Задача сводится к математической задаче оптимизации (минимизации) многомерных функции. Для этого используется алгоритм Нелдера-Мида совместно с методом штрафных функций. Результаты получены только для внешних параметров камер таких, как линейные смещения и вращения.

## Каталоги в этом репозитории

>**demos**: папка, содержащая демонстрацию реализации на примерах <br>
>**matlab**: папка, содержащая код программы

## Дипломная работа

Магистерская работа:<br>

Находится в папке `demos` под названием **DiplomMaster.pdf** <br>
**Google Disk:** https://drive.google.com/file/d/1KFjnYAO5VP8tIxUtCWhuMN4M4qSfuJ0t/view?usp=sharing <br>
**ЯндексДиск:** https://disk.yandex.ru/i/XGQ_HGKpZ3v8Gg

## Результаты компьютерного моделирования

В первом примере вносились случайные искажения положения одной камеры относительно другой (вблизи истинного положения камеры) с амплитудой 8 мм для линейных смещений и 1.6° для вращения. Heading – вращения вокруг оси X, attitude – вокруг оси Z, bank – вокруг оси Y.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/3.png" width="800" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/3_1.png" width="600" /> 
</p>

Во втором примере вносились линейные смещения вдоль оси X. Расчёт с шагом 0,1 мм.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/1.png" width="800" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/1_1.png" width="600" /> 
</p>

В третьем примере вносились искажения во вращение вокруг оси X – heading. Расчёт с шагом 0,02°.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/2.png" width="800" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/2_1.png" width="600" /> 
</p>

## Выводы

По графикам выше видно, что алгоритм хорошо оптимизирует вращения камеры, но не справляется с линейными смещениями. Но даже если линейные смещения не соответствует действительности, то ошибка репроекции всё рано уменьшается. Это говорит о том, что корреляция между ошибкой репроекции и точностью восстановления 3D поверхности не равна **1**, связь вероятно есть, но не всегда уменьшению ошибки репроекции соответствуют уменьшение погрешности восстановления поверхности.

## Результаты решения на реальных изображениях

Экспериментальная установка:<br>
*1 – неподвижная камера; 2 – подвижная камера; 3 – 3-х координатный позиционер; 4 – штатив для камер; <br>5 – объект измерения; 6 – лазерная измерительная установка; 7 – 2-х координатный позиционер лазера; 8 – сервоприводы для деформации поверхности объекта; 9 – дополнительное освещение*

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/ExSystem.png" width="600" />
</p>

Начало отсчёта координат соответствует камере 1, но для удобства на фото выше система координат изображена на 2-ой камере.
В эксперименте сняты пары изображений со смещением камеры 2 с шагом 1, 5, 10 мм вдоль осей X, Y, Z в обе стороны относительно калиброванного положения, для 3-ёх различных форм поверхности.<br>
Первая форма поверхности.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex1.png" width="600" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex1_1.png" width="800" /> 
</p>

Вторая форма поверхности.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex2.png" width="600" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex2_1.png" width="800" /> 
</p>

Третья форма поверхности.

<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex3.png" width="600" />
</p>
<p float="left">
<img src="https://github.com/Stergrim/Recalibration-of-a-stereo-pair-based-on-a-reprojection-error/blob/main/demos/Ex3_1.png" width="800" /> 
</p>

## Выводы
Основные выводы представлены в магистерской работе, здесь будет дополнение.<br>
Как видно из графиков выше ошибку репроекции удалось уменьшить благодаря оптимизации, но из графиков полученных внешних параметров, по которым видно отсутствие закономерности соответствующей линейному перемещению камеры, и результатов компьютерного моделирования, можно сказать что алгоритм вряд ли уменьшил погрешность восстановления 3D поверхности, хотя и не было проведено сравнения измеренной формы поверхности, например, с оптическим триангуляционным датчиком.

## Замечания

Прежде чем выбрать алгоритм Нелдера-Мида были опробованы различные методы: Гаусса, вращающихся направлений Розенброка, Хука-Дживса, БФГШ. Но все они были опробованы только в компьютерном моделировании. С БФГШ не удалось подобрать величину приращения при численном приближении производной для устойчивого поведения алгоритма. Возможно использовались и другие методы, но я уже не помню. Лучший результат показал Нелдер-Мид.<br>
Полученных экспериментальных данных маловато для того, чтобы делать выводы о закономерностях и поведении алгоритма, но получить больше данных не получилось и не планируется развивать это направление.<br>
Также не хватает математической модели или выражения для связи ошибки репроекции с точность восстановления 3D поверхности.<br>
Буду рад аргументированной критике и предложениям.
