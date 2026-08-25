/**
 * BudgetFlow — Geri Bildirim Anketi otomatik oluşturucu (Google Apps Script)
 *
 * KULLANIM:
 * 1. https://script.google.com adresine git → "Yeni proje".
 * 2. Editördeki tüm kodu sil, bu dosyanın içeriğini yapıştır.
 * 3. Üstten "createBudgetFlowSurvey" fonksiyonunu seç ve "Çalıştır" (Run).
 * 4. İlk çalıştırmada Google izin isteyecek → izin ver.
 * 5. Çalışınca "Yürütme günlüğü"nde (Execution log) formun düzenleme ve
 *    paylaşım (testçi) bağlantıları yazdırılır. Paylaşım bağlantısını test
 *    görev metnindeki [ANKET BAĞLANTISI] alanına yapıştır.
 */
function createBudgetFlowSurvey() {
  const form = FormApp.create('BudgetFlow — Test Geri Bildirimi');
  form.setDescription(
    'Birkaç dakikanı alır. Cevapların uygulamayı geliştirmeme doğrudan ' +
    'yardımcı olacak. Teşekkürler!'
  );
  form.setProgressBar(true);
  form.setCollectEmail(false);

  // ── A. Genel ──────────────────────────────────────────────────────────────
  form.addSectionHeaderItem().setTitle('A. Genel');

  form.addTextItem()
    .setTitle('Adın / takma adın (isteğe bağlı)')
    .setRequired(false);

  form.addTextItem()
    .setTitle('Telefon modelin ve Android sürümün')
    .setHelpText('Örn: Samsung A52, Android 13')
    .setRequired(false);

  form.addMultipleChoiceItem()
    .setTitle('Uygulamayı ne sıklıkta açtın?')
    .setChoiceValues(['Her gün', 'Birkaç günde bir', 'Sadece 1-2 kez'])
    .setRequired(true);

  // ── B. Genel deneyim (1-5 ölçek) ──────────────────────────────────────────
  form.addPageBreakItem().setTitle('B. Genel deneyim');

  form.addScaleItem()
    .setTitle('Uygulamayı kullanmak ne kadar kolaydı?')
    .setBounds(1, 5).setLabels('Çok kötü', 'Çok iyi').setRequired(true);

  form.addScaleItem()
    .setTitle('Tasarım/görünüm beğenin?')
    .setBounds(1, 5).setLabels('Çok kötü', 'Çok iyi').setRequired(true);

  form.addScaleItem()
    .setTitle('Hız ve akıcılık?')
    .setBounds(1, 5).setLabels('Çok kötü', 'Çok iyi').setRequired(true);

  // ── C. Özellikler ─────────────────────────────────────────────────────────
  form.addPageBreakItem().setTitle('C. Özellikler');

  const featureOptions = [
    'Çalıştı ve faydalı',
    'Çalıştı ama geliştirilebilir',
    'Sorun yaşadım',
    'Kullanmadım',
  ];
  const features = [
    'İşlem ekleme (gelir/gider)',
    'Notla sınıflandırma ve "Gider Dağılımı"',
    'Grafikler (pasta + son 6 ay)',
    'Arama ve filtreleme',
    'CSV dışa aktarma',
    'Karanlık mod',
  ];
  features.forEach(function (f) {
    form.addMultipleChoiceItem()
      .setTitle(f)
      .setChoiceValues(featureOptions)
      .setRequired(true);
  });

  form.addMultipleChoiceItem()
    .setTitle('Kullanım Kılavuzu yeterince açıklayıcı mıydı?')
    .setChoiceValues(['Evet', 'Kısmen', 'Hayır'])
    .setRequired(true);

  // ── D. Sorunlar ───────────────────────────────────────────────────────────
  form.addPageBreakItem().setTitle('D. Sorunlar');

  form.addMultipleChoiceItem()
    .setTitle('Uygulama hiç çöktü mü veya dondu mu?')
    .setChoiceValues(['Evet', 'Hayır'])
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Evetse, ne yaparken oldu?')
    .setRequired(false);

  form.addParagraphTextItem()
    .setTitle('Anlamadığın ya da kafa karıştıran bir yer oldu mu?')
    .setRequired(false);

  // ── E. İyileştirme ────────────────────────────────────────────────────────
  form.addPageBreakItem().setTitle('E. İyileştirme');

  form.addParagraphTextItem()
    .setTitle('Hangi özelliğin EKLENMESİNİ en çok isterdin?')
    .setHelpText(
      'Fikir: bütçe limiti/uyarı, kategori filtresi, tekrarlayan işlem, ' +
      'hatırlatma bildirimi, para birimi seçimi, yedekleme'
    )
    .setRequired(false);

  form.addParagraphTextItem()
    .setTitle('Çıkarılması ya da basitleştirilmesi gereken bir şey var mı?')
    .setRequired(false);

  // ── F. Kapanış ────────────────────────────────────────────────────────────
  form.addPageBreakItem().setTitle('F. Kapanış');

  form.addScaleItem()
    .setTitle('BudgetFlow’u bir arkadaşına önerir miydin?')
    .setBounds(0, 10).setLabels('Asla', 'Kesinlikle').setRequired(true);

  form.addParagraphTextItem()
    .setTitle('Eklemek istediğin başka bir şey?')
    .setRequired(false);

  // ── Bağlantılar ───────────────────────────────────────────────────────────
  Logger.log('Düzenleme bağlantısı: ' + form.getEditUrl());
  Logger.log('Testçi (paylaşım) bağlantısı: ' + form.getPublishedUrl());
}
