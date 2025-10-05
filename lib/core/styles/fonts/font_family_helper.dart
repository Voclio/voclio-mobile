class FontFamilyHelper{
  FontFamilyHelper._();
  static const String cairoArabic ='Cairo';
  static const String poppinsEnglish ='Poppins';

  static String geLocalizationFontFamily(){
    const currentLanguage = 'ar';
    if(currentLanguage =='ar'){
      return cairoArabic;
    }else{
      return poppinsEnglish;
    }
  }
}