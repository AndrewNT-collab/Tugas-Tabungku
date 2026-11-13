import 'package:flutter/material.dart';

void main() {
  runApp(const TabungKuApp());
}

const Color navy = Color(0xFF101D46);
const Color navyLight = Color(0xFF1B3266);
const Color orange = Color(0xFFFF8A00);
const Color backgroundColor = Color(0xFFF4F6FC);
const double radius = 10;

class Transaksi {
  final String judul;
  final String tanggal;
  final int nominal;
  final IconData ikon;
  final bool masuk;

  const Transaksi({
    required this.judul,
    required this.tanggal,
    required this.nominal,
    required this.ikon,
    required this.masuk,
  });
}

String formatRupiah(int angka) {
  final hasil = angka.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
  );
  return 'Rp $hasil';
}

String tanggalSekarang() {
  final now = DateTime.now();
  const bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  return '${now.day} ${bulan[now.month - 1]} ${now.year}';
}

class TabungKuApp extends StatelessWidget {
  const TabungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TabungKu',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
      ),
      home: const RingkasanPage(),
    );
  }
}

class RingkasanPage extends StatefulWidget {
  const RingkasanPage({super.key});

  @override
  State<RingkasanPage> createState() => _RingkasanPageState();
}

class _RingkasanPageState extends State<RingkasanPage> {
  int saldo = 3400000;
  final int target = 5000000;

  final List<Transaksi> transaksi = [
    const Transaksi(
      judul: 'Menabung',
      tanggal: '13 November 2026',
      nominal: 500000,
      ikon: Icons.savings_outlined,
      masuk: true,
    ),
    const Transaksi(
      judul: 'Penarikan Uang',
      tanggal: '10 November 2026',
      nominal: 200000,
      ikon: Icons.account_balance_wallet_outlined,
      masuk: false,
    ),
    const Transaksi(
      judul: 'Menabung',
      tanggal: '05 November 2026',
      nominal: 750000,
      ikon: Icons.savings_outlined,
      masuk: true,
    ),
  ];

  Future<void> _prosesTransaksi(bool masuk) async {
    final nominal = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return DialogNominal(
          judul: masuk ? 'Menabung' : 'Tarik Tabungan',
        );
      },
    );

    if (!mounted || nominal == null) return;

    if (!masuk && nominal > saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo tidak mencukupi untuk penarikan.'),
        ),
      );
      return;
    }

    setState(() {
      saldo += masuk ? nominal : -nominal;
      transaksi.insert(
        0,
        Transaksi(
          judul: masuk ? 'Menabung' : 'Penarikan Uang',
          tanggal: tanggalSekarang(),
          nominal: nominal,
          ikon: masuk
              ? Icons.savings_outlined
              : Icons.account_balance_wallet_outlined,
          masuk: masuk,
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          masuk
              ? 'Berhasil menambahkan tabungan!'
              : 'Penarikan berhasil!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _tampilkanRiwayat() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(radius),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: transaksi.isEmpty
                        ? const Center(
                      child: Text('Belum ada transaksi.'),
                    )
                        : ListView.builder(
                      itemCount: transaksi.length,
                      itemBuilder: (context, index) {
                        return _buildTransaksi(transaksi[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pilihMenu(String judul) {
    if (judul == 'Menabung') {
      _prosesTransaksi(true);
    } else if (judul == 'Tarik') {
      _prosesTransaksi(false);
    } else {
      _tampilkanRiwayat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ringkasan Tabungan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _tampilkanRiwayat,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool tablet = constraints.maxWidth >= 600;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: tablet ? 32 : 18,
              vertical: 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Halo, Selamat Datang!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Yuk, capai target tabunganmu!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildCardRingkasan(),
                    const SizedBox(height: 28),
                    const Text(
                      'Menu Utama',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMenu(
                            Icons.add_circle_outline,
                            'Menabung',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenu(
                            Icons.arrow_downward,
                            'Tarik',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMenu(
                            Icons.receipt_long_outlined,
                            'Riwayat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Transaksi Terakhir',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: navy,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _tampilkanRiwayat,
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...transaksi.take(3).map(_buildTransaksi),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'TabungKu - Kelola Tabunganmu',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardRingkasan() {
    final double progress = (saldo / target).clamp(0.0, 1.0);

    return Card(
      color: navy,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool sempit = constraints.maxWidth < 380;

            final saldoWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tabungan Masa Depan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Total Saldo',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatRupiah(saldo),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );

            final targetWidget = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Tabungan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatRupiah(target),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!sempit)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: saldoWidget),
                      const SizedBox(width: 12),
                      targetWidget,
                    ],
                  )
                else ...[
                  saldoWidget,
                  const SizedBox(height: 18),
                  targetWidget,
                ],
                const SizedBox(height: 22),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(orange),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progres Tabungan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenu(IconData ikon, String judul) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => _pilihMenu(judul),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: navy.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: orange.withOpacity(0.15),
                child: Icon(
                  ikon,
                  color: orange,
                  size: 25,
                ),
              ),
              const SizedBox(height: 9),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  judul,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransaksi(Transaksi item) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: item.masuk
              ? Colors.green.withOpacity(0.12)
              : Colors.red.withOpacity(0.12),
          child: Icon(
            item.ikon,
            color: item.masuk ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          item.judul,
          style: const TextStyle(
            color: navy,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          item.tanggal,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Text(
          '${item.masuk ? '+' : '-'}${formatRupiah(item.nominal)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: item.masuk ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}

class DialogNominal extends StatefulWidget {
  final String judul;

  const DialogNominal({
    super.key,
    required this.judul,
  });

  @override
  State<DialogNominal> createState() => _DialogNominalState();
}

class _DialogNominalState extends State<DialogNominal> {
  final TextEditingController controller = TextEditingController();
  String? error;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _simpan() {
    final nominal = int.tryParse(
      controller.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    if (nominal == null || nominal <= 0) {
      setState(() {
        error = 'Masukkan nominal yang valid.';
      });
      return;
    }

    Navigator.of(context).pop(nominal);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      title: Text(
        widget.judul,
        style: const TextStyle(
          color: navy,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan nominal uang',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              onSubmitted: (_) => _simpan(),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Contoh: 100000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: const BorderSide(color: navy),
                ),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: navy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          onPressed: _simpan,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
