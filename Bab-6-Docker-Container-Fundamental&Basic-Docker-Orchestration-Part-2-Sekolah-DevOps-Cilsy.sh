#Docker Container Fundamental & Basic Docker Orchestration di Server Production Part 2 #

#6.1. Konsep Networking pada Docker:
#Selama kita praktek container pada materi-materi sebelumnya, kita sama sekali tidak pernah
#menjamah terkait IP dan topologi. Padahal jika kita biasa bermain-main di dunia jaringan dan
#server, justru hal yang pertama kali harus kita setup dan desain adalah terkait hal ini. Kenapa
#hal ini bisa terjadi?
#Secara kasat mata, ip dari Container-container kita adalah localhost atau sesuai dengan IP
#dari hostnya masing-masing. Terbukti dari saat kita mengakses container NGINX, kita selalu
#membuka alamat ip localhost (dan sebenarnya bisa diakses menggunakan ip dari Hostnya).
#Secara default, hal ini kurang benar. Karena sebenarnya Container-container kita memiliki IP
#nya masing-masing dan berbeda dengan IP Host. Cobalah jalankan sebuah Container NGINX
#lalu eksekusi command berikut untuk melihat ip dari container tersebut :

$ docker container run ­d ­p 8080:80 ­­name nginxhost nginx
$ docker container inspect nginxhost

#Dari hasil informasi yang keluar, carilah bagian Networks yang kira-kira tampilannya seperti
#ini :

#Disana terlihat bahwa IP Address dari Container ini adalah 172.17.0.2. (di module ada kesalahan IP Address)
#Lalu cobalah lihat IP Host Anda masing-masing :

$ ifconfig (Linux & Mac)
$ ipconfig (Windows)

#Contohnya disini yang tampil adalah IP 192.168.43.63 :

#6.1.2. Apakah Networking Docker hanya ini?
#1. Bridge.
#Ini adalah driver default yang digunakan pada Private Networking yang sudah kita
#jelaskan sebelumnya. Dimana Container ditempatkan dalam Private Network dan
#dipisahkan oleh Firewall. Opsi yang paling aman.
#2. Host
#Ini adalah driver untuk membuat Container tidak dimasukkan kedalam Private
#Networking, namun langsung dihubungkan pada Host. Misal IP Host adalah
#192.168.43.61, maka Container akan mendapatkan IP 192.168.43.62. Kurang aman,
#namun kecepatan traffic menjadi lebih cepat.
#3. Null
#Ini ketika kita ingin Container kita tidak dihubungkan ke jaringan manapun. 

#6.2. Docker CLI Networking

#Jika sebelumnya kita sudah mempelajari konsep-konsep pada Networking, disini kita akan
#mempraktekkan command-command yang bisa digunakan untuk merealisasikan desain
#networking yang kita inginkan.

#6.2.1. Docker Network Create dan Remove
#Untuk membuat sebuah Network baru, format commandnya adalah sebagai berikut :

$ docker network create ­­driver <nama driver> <nama network>
#Contoh :
$ docker network create ­­driver bridge kuasai_net

#Setelah Network terbuat, seterusnya ketika kita ingin menjalankan Container dapat
#menggunakan opsi --network untuk langsung menghubungkan Container tersebut ke

#Network yang kita inginkan. Contohnya :
$ docker container run ­d ­­network kuasai_net ­­name nginx nginx

#Jika ada Network yang tidak terpakai lagi kita dapat menghapusnya menggunakan perintah
#berikut :

$ docker network rm <nama network> 
#Contoh :
$ docker network rm kuasai_net

#6.2.2. Docker Network Connect
#Bagaimana ketika kita ingin menghubungkan Container yang sudah terlanjur berjalan ke
#Network tertentu? Kita dapat menggunakan perintah berikut :

$ docker network connect <nama network> <nama container>
#Misal kita ingin hubungkan Container nginxhost ke network kuasai_net maka perintahnya :
$ docker network connect kuasai_net nginxhost

#6.2.3. Docker Network Disconnect:
#Lalu bagaimana kalau kita ingin mencopot NIC/memutuskan suatu Container dari suatu
#network? Kita dapat menggunakan perintah disconnect :

$ docker network disconnect <nama network> <nama container>
#Contohnya kita ingin memutuskan network default yaitu bridge dari container nginxhost :
$ docker network disconnect bridge nginxhost

#Cobalah lakukan inspect kembali pada container nginxhost untuk memastikan bahwa kini
#Container nginxhost hanya terkoneksi ke network kuasai_net saja.


#6.2.4. Docker Network ls
#Karena kita bisa membuat banyak Network, tentunya kita bisa me-listing network apa saja
#yang sudah kita buat dengan perintah :

$ docker network ls

#6.2.5. Docker Network Inspect
#Sama dengan perintah docker container inspect, command ini juga untuk menampilkan
#metadata berupa informasi lengkap bagaimana suatu Network dijalankan :

$ docker network inspect <nama network>
#Contoh :
$ docker network inspect kuasai_net

#Contohnya kita bisa melihat container mana saja yang sedang terkoneksi pada Network
#tersebut, berapa ipnya dsb.

#6.4. Terkait DNS dan Bagaimana Komunikasi Container yang baik:

#6.4.2. Praktek Simpel DNS
#Contoh bukti bahwa fungsi DNS ini sudah berjalan secara otomatis dapat kita test
#menggunakan command ping sederhana saja.
#Misal kita coba jalankan 1 Container yang baru di dalam private network yang sama dengan
#container nginxhost, yaitu kuasai_net.

$ docker container run ­it ­­rm ­­network kuasai_net ­­name alpine alpine ping  nginxhost

#6.4.3. Kenapa DNS Round Robin?:

#Seringkali dalam sebuah layanan yang disajikan kepada user, sebenarnya ada beberapa
#container dibaliknya. Misalnya seperti website Google.com itu pasti memiliki banyak
#Container di belakangnya, walaupun websitenya hanya 1.
#Untuk itulah fitur DNS Round Robin ini digunakan. Dimana kita dapat menentukan 1 nama
#untuk beberapa container. Sistem Docker lah yang nanti akan menentukan secara random
#container mana (dari daftar container yang sudah ditentukan) yang harus menjawab.
#Misalnya begini :
#Nama domain : sdcilsy-alpha.web.id
#Daftar Container :
#• ContainernginxA
#• ContainernginxB
#• ContainernginxC

#6.4.4. Praktek DNS Round Robin
#Kita coba skenario bahwa kita memiliki 3 buah container nginx tapi menggunakan 1 buah
#panggilan yaitu nginx. Kita bisa gunakan opsi --net-alias seperti berikut :

$ docker container run ­d ­­network kuasai_net ­­net­alias nginx nginx 
$ docker container run ­d ­­network kuasai_net ­­net­alias nginx nginx
$ docker container run ­d ­­network kuasai_net ­­net­alias nginx nginx

#Berhubung kita tidak menentukan nama dari containernya, kita bisa lakukan perintah
#tersebut sebanyak 3 kali seperti diatas untuk membuat 3 buah container nginx dengan nama
#random.
#Selanjutnya kita coba testing dengan menggunakan tools nslookup dan ping :

$ docker container run ­it ­­rm ­­network kuasai_net alpine nslookup nginx
$ docker container run ­it ­­rm ­­network kuasai_net alpine ping nginx

#6.7.3. Bagaimana cara mengunduh berbagai macam image:
#6.7.3.1. Melihat list image yang ada di local
#Image-image yang kita sudah kita unduh/pull dari Docker Hub akan tersimpan di local Host
#kita. Kita dapat melihatnya dengan perintah berikut :

$ docker image ls

#6.7.3.2. Image ID vs Tag:

#Semua tag tersebut dapat digunakan dengan format berikut :
$ docker image pull nginx:<tag>
#Contoh :
$ docker image pull nginx:1.15
$ docker image pull nginx:1.15.4
$ docker image pull nginx
$ docker image ls

#6.8. Image Layer:

#Kita juga dapat coba mengecek bahwa benar image ini terdiri dari layer-layer menggunakan
#command berikut :
$ docker image history <nama image>
#Contoh :
$ docker image history mysql

#6.9.1. Praktek Image Tagging:
#Untuk melakukkan tagging dari sebuah image ke image kita sendiri, kita dapat menggunakan
#format berikut :
#Untuk official image
$ docker image tag <source_image>:<tag> <username>/<dst_image>:<tag>
#Contoh :
$ docker image tag nginx:1.15.4 cilsy/nginxmyapp:1.15.4
$ docker image tag nginx cilsy/nginxmyapp
#Untuk non-official
$ docker image tag <username>/<source_image>:<tag> <username>/<dst_image>:<tag>
#Contoh :
$ docker image tag bitnami/wordpress:4.9.8 cilsy/wordpresscustom:4.9.8
$ docker image tag bitnami/wordpress cilsy/wordpresscustom
#Cek hasilnya menggunakan command :
$ docker image ls

#6.9.2. Docker Login
#Untuk bisa melakukan Push Image ke Docker Hub pertama-tama kita harus menghubungkan
#terlebih dahulu Host docker kita ke akun Docker Hub yang sudah kita miliki. Caranya dengan
#mengetikkan perintah berikut :
$ docker login
#Lalu isikan username dan password Anda masing-masing. Pastikan Anda mendapatkan pesan
#berhasil login seperti ini :

#6.9.3. Push Image ke Docker Hub:
#Untuk melakukan push image yang sudah kita tagging sebelumnya caranya sangat mudah.
#Kita tinggal mengeksekusi perintah berikut :
$ docker image push <nama user docker hub>/<nama image>:<tag>
#Contohnya disini saya ingin memberikan tag latest saja sehingga commandnya menjadi
#seperti ini :
$ docker image push cilsy/nginxmyapp
#Nantinya kita bisa juga menggunakan tag-tag tambahan seperti :
$ docker image push cilsy/nginxmyapp:1.15.1
#Atau :
$ docker image push cilsy/nginxmyapp:staging
#Bebas bisa disesuaikan dengan kebutuhan kita masing-masing.

#6.12. Building image : Running Docker Builds:
#Perintah untuk build image formatnya adalah sebagai berikut :
$ docker image build ­t <nama image yang diinginkan>:<tag> .
#Nb : perintah diatas hanya bisa dilakukan jika kita berada di dalam folder yang sudah
#terdapat Dockerfile dan nama Dockerfilenya benar-benar bernama “Dockerfile”.
#Contoh :
$ docker image build ­t nginxbebas .
#Apabila nama Dockerfilenya selain dari defaultnya, maka bisa gunakan perintah ini :
$ docker image build ­f <nama Dockerfile> ­t <nama image yang 
#diinginkan>:<tag> .
#Contoh :
$ docker image build ­f dockerfile­nginx ­t nginxbebas .
#Misalnya kita coba build image nginx tersebut :
$ docker image build ­t nginxbebas .

#Maka kita bisa lihat bahwa akan terjadi banyak proses yang dijalankan sesuai commandcommand 
#yang sudah ditentukan di dalam Dockerfile, seperti perintah RUN, perintah
#EXPOSE, perintah CMD.

#Setelah proses build selesai, cobalah ulangi perintah build yang sama dan perhatikan apa
#yang terjadi :
$ docker image build ­t nginxbebas .
#Proses yang tadinya cukup lama, sekarang hanya berjalan tidak sampai 1 detik. Kenapa hal ini
#bisa terjadi?
#Sekarang coba perhatikan gambar dibawah ini :

#Terlihat bahwa pada setiap command diatas muncul tulisan “Using Cache”. Ini artinya
#command tersebut masih merupakan layer image yang sama dengan yang tersimpan di local
#sehingga tidak perlu dieksekusi kembali.
#Sebuah image layer dinyatakan sama ketika :
#1. Isi commandnya persis sama
#2. Urutan commandnya sama

#6.13.2. Push ke Docker Hub
#Untuk melakukan push ke Docker Hub, seperti biasa kita harus mengubah tagging image ini
#menjadi format :
#<nama user di Docker hub>/<nama image>:<tag>
#Berikut adalah contohnya (disini kita menggunakan tag latest saja) :
$ docker image tag nginx­custom:latest cilsy/nginx­custom:latest
#Setelah sudah diubah tagnya, langsung lakukan push dengan perintah berikut :
$ docker image push cilsy/nginx­custom

#Sampai tahap ini seharusnya image anda sudah masuk ke Docker Hub. Sebagai testing, kita
#akan coba menghapus image nginx-custom dari local untuk nantinya kita akan coba
#mengambil ulang image ini dari Docker Hub.
#Pertama-tama kita coba hapus terlebih dahulu image nginx-custom dari local :
$ docker image rm cilsy/nginx­custom
$ docker image rm nginx­custom
#Setelah itu kita coba jalankan container menggunakan image ini, tapi dengan langsung pull
#ulang image ini dari Docker Hub :
$ docker container run ­p 80:80 ­­rm cilsy/nginx­custom

#Anda bisa coba lihat bagian yang ditandai merah, bahwa image cilsy/nginx-custom sudah
#tidak dapat ditemukan di local dan Docker akan mengambilnya dari Docker Hub. Setelah
#running, pastikan ketika Anda test di browser, container ini tetap membuka halaman custom
#nginx seperti sebelumnya.







