# IPBD Kelompok 8 - Tugas CDC dengan Debezium
<p align="center">
  Prayuda Afifan Handoyo | L0224008 | Kelas A<br>
  Meiva Yusnita Amalia W. K. | L0224044 | Kelas A<br>
  Infrastruktur dan Platform Big Data
</p>

Proyek ini melakukan **Change Data Capture (CDC)** dari **PostgreSQL** (source) ke **SQL Server** (destination) menggunakan **Debezium**.

## Arsitektur

```
PostgreSQL (source:5432) → Debezium Connect → Kafka → Debezium JDBC Sink → SQL Server (dest:1434)
```

- **Zookeeper** — koordinasi Kafka
- **Kafka** — message broker
- **Kafka UI** — monitoring topik Kafka (port 8070)
- **Debezium Connect** — konektor source (PostgreSQL) dan sink (SQL Server) — menggunakan `network_mode: host`
- **PostgreSQL** — database sumber dengan `wal_level=logical`
- **SQL Server** — database tujuan

## Prasyarat

- Docker & Docker Compose
- Port kosong: `2181`, `9092`, `8070`, `8083`, `5432`, `1434`

## Setup

### 1. Clone repositori

```bash
git clone https://github.com/prayudahlah/cdc-ipbd-kelompok8
cd cdc-ipbd-kelompok8
```

### 2. Siapkan environment variables

```bash
cp .env.example .env
```

Sesuaikan nilai di `.env` jika perlu. Nilai default sudah sesuai untuk menjalankan semua service.

### 3. Jalankan service source (PostgreSQL + Kafka + Zookeeper + Debezium)

```bash
docker compose -f compose.source.yaml up -d --build
```

Tunggu beberapa saat sampai semua container siap.

### 4. Daftarkan source connector (PostgreSQL → Kafka)

```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @source-connector.json
```

### 5. Jalankan service destination (SQL Server)

```bash
docker compose -f compose.destination.yaml up -d
```

Tunggu ~30 detik hingga SQL Server selesai inisialisasi dan database `kuliah` terbentuk.

### 6. Daftarkan sink connector (Kafka → SQL Server)

```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d @sink-connector.json
```

> **Catatan:** `sink-connector.json` menggunakan hostname `meiva` untuk menjangkau SQL Server. Jika hostname mesin Anda berbeda, sesuaikan nilai `connection.url` di file tersebut.

## Verifikasi

Cek daftar connector:

```bash
curl http://localhost:8083/connectors
```

Cek topik Kafka di Kafka UI: http://localhost:8070

Coba insert data ke PostgreSQL:

```bash
docker exec -i postgres-source psql -U postgres -d kuliah <<< "INSERT INTO mahasiswa VALUES ('12345678', 'John Doe', '2000-01-01');"
```

Data akan otomatis tersinkronisasi ke SQL Server.

Cek di SQL Server:

```bash
docker exec -i sqlserver-dest /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P 'YourStrong@Passw0rd' -C \
  -d kuliah -Q "SELECT * FROM mahasiswa;"
```

## File Penting

| File | Fungsi |
|---|---|
| `compose.source.yaml` | Service source: Zookeeper, Kafka, Kafka UI, Debezium, PostgreSQL |
| `compose.destination.yaml` | Service destination: SQL Server |
| `init-source.sql` | Inisialisasi tabel `mahasiswa` di PostgreSQL |
| `init-destination.sh` | Inisialisasi database `kuliah` di SQL Server |
| `source-connector.json` | Konfigurasi Debezium source connector PostgreSQL |
| `sink-connector.json` | Konfigurasi Debezium JDBC sink connector SQL Server |
| `Dockerfile` | Debezium Connect image with MSSQL JDBC driver |
| `.env` | Variabel lingkungan (user, password, dll) dari template `.env.example` |
| `.env.example` | Template variabel lingkungan |
| `.gitignore` | Daftar file yang diabaikan Git |
