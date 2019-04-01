#Bab 6 - Docker Container Fundamental & Basic Docker Orchestration Part 1#

#install docker:

curl ­fsSL get.docker.com ­o get­docker.sh
chmod +x get­docker.sh
sh get­docker.sh

#Instalasi Docker Compose dapat dilakukan dengan mengeksekusi script berikut :

$ sudo curl ­L  "https://github.com/docker/compose/releases/download/1.22.0/docker­compose­$(uname ­s)­$(uname ­m)" ­o /usr/local/bin/docker­compose
$ sudo chmod +x /usr/local/bin/docker­compose
$ sudo docker­compose ­­version

#Sedangkan untuk Docker Machine bisa eksekusi perintah berikut :

$ base=https://github.com/docker/machine/releases/download/v0.14.0
$ curl ­L $base/docker­machine­$(uname ­s)­$(uname ­m) >/tmp/docker­machine
$ sudo install /tmp/docker­machine /usr/local/bin/docker­machine

#Untuk mengecek seluruh hasil instalasi dapat mengetikkan perintah berikut di terminal/cmd :

$docker version
$docker­compose ­­version
$docker­machine ­­version


#Perintah-Perintah Dasar Docker:

$docker version

#Docker info merupakan command untuk mendapatkan informasi sistem docker secara keseluruhan:

d$ocker info

#Docker Command Structure

#Ada 2 buah struktur command pada Docker yaitu :
#1.Struktur Lama
#docker <command> (options)
#Contoh :

$docker run ­p 80:80 mysql
$docker rm containerA
$docker inspect

#2. Struktur Baru
#docker <command> <sub­command> (options)
#Contoh :
$docker container run ­p 80:80 mysql
$docker container rm containerA
$docker container inspect

#Manajemen Container
#Menjalankan Container Baru
#docker container run <options> image

$docker container run ­p 80:80 ­­name nginxhost nginx

#Kita juga biasanya tidak menginginkan Container berjalan dalam terminal yang aktif. Karena
#jika kita jalankan Container dalam terminal aktif, ketika layar terminal ini kita tutup atau kita
#tekan CTRL + C maka container tersebut akan berhenti. Oleh karena itu kita bisa jalankan
#Container dengan opsi -d (detach mode) :

$ docker container run ­d ­p 80:80 ­­name nginxhost nginx

#Melihat Container yang Berjalan dan Menghentikannya:

$ docker container ls

# $ docker container stop <container name>

$ docker container stop nginxhost
$ docker container ls  #untuk melihat containers yang berjalan
$ docker container ls ­a #untuk melihat containers yang berjalan dan berhenti

#Menjalankan Container yang sudah dihentikan:

$ docker container start <container name>
#contoh >>
$ docker container start nginxhost
 
#Docker Logs dan Top:
$ docker container logs <container name>
# Contoh :
$ docker container logs nginxhost

#Kita juga dapat meliha proses apa saja yang dijalankan oleh suatu Container menggunakan
#perintah “top”. Ini biasa kita gunakan untuk menganalisa container mana yang misalnya
#memakan RAM paling besar karena terlalu banyak menjalankan proses. Perintah top ini
#sangat mirip dengan perintah top Linux pada umumnya :

$ docker container top <container name>
#contoh >>
$ docker container top nginxhost

#Menghapus Container:

#Untuk menghapus container kita dapat menggunakan perintah berikut :
$ docker container rm <container name>
#Contoh :
$ docker container rm nginxhost
#Namun perintah hapus ini tidak akan bisa digunakan pada Container yang sedang dalam
#keadaan berjalan. Kita dapat menggunakan opsi -f untuk memaksa menghapus container
#yang sedang berjalan :
$ docker container rm ­f <container name>
#Contoh :
$ docker container rm ­f nginxhost

#6.6. Menggali Lebih dalam yang terjadi saat Container dijalankan:

$ docker container run ­d ­p 80:80 ­­name httpdhost httpd

#Maka yang terjadi adalah :
#1. Pertama-tama Docker akan mencari image bernama httpd di registry local terlebih dahulu.
#2. Karena image httpd belum ada di lokal, maka Docker akan mengambil image httpd
#dari registry publik yaitu Docker Hub. Jika kita tidak menentukan versi spesifik dari
#image yang ingin kita ambil, maka secara default Docker akan mengambil image
#dengan tag “latest”. Kita dapat tentukan versi tertentu misalnya httpd:1.11.1.
#3. Sebuah container baru bernama httpdhost akan dijalankan menggunakan image httpd tersebut.
#4. Virtual IP dan private network akan dipasang pada Container tersebut.
#5. Perintah -p (publish) membuat port 8080 pada host akan di buka.
#6. Seluruh traffic menuju port 8080 dari host akan di arahkan ke port 80 pada container httpdhost.

#Dari banyaknya proses ini, kita dapat memodifikasi perintah docker run berdasarkan kebutuhan :

$ docker container run ­d ­p 8080:80 ­­name httpdhost httpd:2.4.35 httpd ­e debug 

#Misalnya pada perintah diatas kita mengubah port host yang awalnya 80 menjadi 8080,
#mengubah versi image httpd menjadi 2.4.35 dan menggunakan Command custom berupa
#“httpd -e debug” dimana command ini merupakan command untuk menjalankan webserver
# httpd dengan mode log debug.

#6.7. Container vs VM
#Seringkali materi yang membahas terkait Container selalu membandingkan Container dengan VM seperti ini :
#Ada yang menyebut Container adalah mini VM juga. Padahal bahkan Container bisa dibilang
#tidak bisa sama sekali dibandingkan dengan VM. Karena Container hanya menjalankan
#sebuah proses pada Host, layaknya kita menjalankan sebuah aplikasi Firefox di OS Windows.
#Untuk lebih mudah memahaminya kita coba jalankan sebuah container menggunakan image mongodb :

$ docker container run ­d ­­name mongo mongo

#Kemudian kita coba lihat proses apa saja yang muncul dari container ini :

$ docker container top mongo

#Terlihat ada sebuah proses dengan PID 10047 yang menjalankan command mongod. Di
# Linux, setiap proses akan memiliki ID unik tersendiri bernama PID. 

#Nah sekarang kita buktikan bahwa sebenarnya proses ini hanyalah proses yang dijalankan di
#host layaknya aplikasi biasa. Kita dapat menggunakan perintah :

$ ps aux

#Disana terlihat ada proses mongodb dari sekian banyak proses yang berjalan di host
#tersebut. Bahkan jika Anda teliti lebih dalam, pada gambar diatas juga ada proses yang
#menjalankan Google Chrome. Artinya disini level mongodb dan Google Chrome itu setara,
#sama-sama hanya sebuah proses.
#Anda bisa coba hentikan container Mongodb tersebut dan bandingkan bahwa proses
#mongodb sudah menghilang dari host.
#Inilah yang menyebabkan kenapa Container begitu ringan, jauh dibandingkan dengan VM.
#Jika kita menjalankan mongodb di dalam VM maka kita perlu menjalankan OS yang lengkap
#beserta seluruh proses-proses yang lengkap pula di dalamnya. Sedangkan jika pada
#Container, hanya cukup menjalankan 1 proses mongodb itu saja, tidak ada proses-proses
#lainnya.

#6.8. Monitoring Container
#6.8.1. Top
#Ini merupakan perintah untuk menampilkan list proses apa saja yang dijalankan oleh sebuah
#Container.

#Sebelumnya kita coba jalankan 2 buah container terlebih dahulu :
$ docker container run ­d ­p 80:80 ­­name nginx nginx
$ docker container run ­d ­­name mongo mongo

#Setelah itu coba lihat masing-masing proses yang dijalankan oleh masing-masing container
#tersebut :
$ docker container top nginx
$ docker container top mongo

#6.8.2. Inspect
#Command Inspect akan menampilkan informasi yang sangat lengkap terkait konfigurasi
#bagaimana Container ini dijalankan. Kita coba lihat dengan perintah berikut :

$ docker container inspect <nama container>

#Contoh :

$ docker container inspect nginx
#Disana anda akan mendapatkan informasi yang begitu banyak seperti berapa virtual ip dari
#container ini, hostnamenya apa, dll.

#6.8.3. Stats
#Command ini memberikan kita informasi sederhana terkait statistik penggunaan dari setiap
#container yang berjalan. Seperti berapa penggunaan RAM, CPU, dan Network dari setiap
#Container.
#Misalnya pada gambar diatas kita dapat melihat bahwa container mongo memakan RAM
#39MB saat container baru dijalankan.

$ docker container stats

#6.9. Masuk ke dalam Container:
#6.9.1. Menjalankan Container dengan mode Interaktif:

$ docker container run ­it nginx bash

#Diatas adalah contohnya kita menjalankan container menggunakan image nginx secara mode
#interaktif dengan shell Bash. Hasilnya Anda akan mendapatkan shell seperti berikut :

root@3642bcc47543:/# 

#Jika sudah didalam shell container seperti ini, maka semua command yang kita lakukan akan
#terjadi di dalam container tersebut, bukan pada Host.
#Contohnya disini kita bisa mengeksekusi perintah cat /etc/nginx/nginx.conf untuk melihat isi
#dari konfigurasi NGINX kita :

root@3642bcc47543:/# cat /etc/nginx/nginx.conf 

#Bahkan kita dapat melakukan instalasi paket tambahan seperti nano :

root@3642bcc47543:/# apt­get update && apt­get install nano
root@3642bcc47543:/# nano /etc/nginx/nginx.conf

#Jika sudah selesai, Anda dapat mengetikkan exit untuk keluar dari Shell. Sayangnya jika kita
#sudah keluar dari Shell seperti ini, maka container otomatis akan dihentikan. 

#6.9.2. Docker Exec
#Lalu bagaimana agar Container tetap berjalan dan kita tetap bisa masuk ke dalam Shell ?
#Pertama-tama kita perlu untuk menjalankan Container seperti biasa dengan mode detach.

$ docker container run ­d ­p 80:80 ­­name nginx nginx

#Container nginx ini sama sekali tidak memiliki mode interaktif bukan? Namun kita tetap bisa
#masuk ke dalamnya menggunakan command Exec. Berikut adalah contohnya :

$ docker container exec ­it nginx bash

#Maka kita akan masuk ke dalam shell mode interaktif, sama seperti yang kita bahas
#sebelumnya. Saat kita exit dari shell pun container tetap akan berjalan, karena Docker Exec
#ini sifatnya hanya sebagai proses tambahan bukan proses utama dari Containernya itu
#sendiri.









