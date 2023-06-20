# DDAPP-10 

SEVEN SEGMENT DISPLAY 
Bu projemizde Basys3 FPGA boardunu kullanarak, board üzerinde bulunan 4 adet seven-segment-display' ler ile bir sayaç tasarımı yapacağız.

## İçerikler

- [Proje Hakkında](#proje-hakkında)
- [Kurulum](#kurulum)
- [Kullanım](#kullanım)
- [Katkıda Bulunma](#katkıda-bulunma)
- [Lisans](#lisans)

## Proje Hakkında

Basys3 züerindeki 4 adet seven-segment-display ile en sağdaki (0) anottan "0" ile başlayan ve her bir saniyede bir sayı arttırarak displayler üzerinde bir sayaç oluşturacağız. Bu projenin, kullanıcı açısından amacı: Basys3'ü ve donanım dili olan 
VHDL'e kullanıcının aşinalığı artacak. Ayrıca donanım programlamada kilit noktalardan biri olan "clock" düzenleme ve bölme işlemlerinin burada ilk etapta anlaşılması beklenmektedir. Projenin açıklama satırlarında yapılan işlemlerin detayları
bulunmaktadır. Bu proje aynı zamanda dış kaynaktan alınan ".bit " dosyasının nasıl işlenmesi gerektiğini de bize açıklayacaktır.




## Kurulum
  
  1- Kişisel bilgisayarınıza Seven-Segment-Display Klasörünü indiriniz.
  2- İndirdiğiniz "zip" dosyasını, belirteceğiniz bir klasöre ayıklayınız.
  3- Eğer kişisel bilgisayarınızda bulunmuyor ise; "Xilinx Vivado 2020.2" veyahut son sürümlerinden birini kurunuz. Kurulum için belirtilen linkten faydalanabilirsiniz:
  4- Ayıkladığınız dosyaların içindeki ".xpr"  Vivado Project File dosyasına çift tıklayarak veya birlikte aç -> Vivado ile açınız.
  5- Projeniz açıldığında proje ekranının sağ üst köşesinde "write_bitstream_Complate" ve ✅ görüyorsanız projeniz board'a aktarım için hazırdır.
  6- Eğer "Synthesis and Implementation Out-of-date" yazısını görüyorsanız: Vivado flow navigator'dan "Program and Debug" altındaki "Generate Bitstream" e tıklayınız. Launch Runs ekranından "OK" a tıklayarak devam ediniz. Bu işlem biraz zaman alabilir.
  6- write_bitstream_Complate'i gördükten sonra yine "Program and Debug" altındaki 'Open Hardware Manager' butonuna tıklayınız. Bu aşamada USB ile Basys3'ü kişisel bilgisayarınıza bağlayınız.
  7- Basys3 üzerindeki 'power' ledinden cihazın güç alıp almadığını anlayabilirsiniz. 'power' ledi yanmıyorsa: power switch'ini açık konuma getirmemiş veyahut bağlantı kablonuzda bir sıkıntı yaşıyor olabilirsiniz. 
  8- Power ledi yandığından yine Vivado üzerinden 'Open hardware Manager' altındaki "open Target" -> "auto connect" butonuna tıklayınız. Bu Kişisel bilgisayarınız ile FPGA arasındaki bağlantıyı otomatik olarak sağlayacaktır.
  9- Bağlantı başarısısz olursa vivado size bir uyarı verecektir. Bu durumda adımları tekrarlayıp tekrar deneyiniz.
  10- Bağlantı kurulduktan sonra cihazımızı programlayabiliriz. Cihazı programlamak için 'Open Hardware Manager' altındaki "program Device" butonuna tıklayalım. 
  11- Program Device bloğu önümüze, programlama yapmak için hangi '.bit' dosyasını kullanacağını soracaktır. .bit dosyaları projemizin içinde var olduğundan vivadonun otomatik yerleştirdiği bit dosyasını kullanarak devam ediniz ve "Program" butonuna basınız.
  12- Basys3'ü programladık. Programı resetlemek isterseniz board üzerindeki "PROG" butonunu kullanabilirsiniz.

## Kullanım



## Katkıda Bulunma





