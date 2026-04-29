# 레이턴시 참조 카드 (아키텍처 설계용)

> 출처: Norvig(2001) → Jeff Dean LADIS 2009 → jboner gist(2012) → napkin-math(2026 재측정)
> 설계 제안 시 아래 수치를 **정량 근거**로 사용. 절댓값 암기보다 차수(order of magnitude) 감각이 핵심.

## 핵심 레이턴시 수치 (2026 기준)

| 연산 | 레이턴시 | 비고 |
|------|---------|------|
| L1 캐시 참조 | 0.5 ns | CPU 레지스터 수준 |
| L2 캐시 참조 | 7 ns | L1 대비 14× |
| 뮤텍스 락/언락 | 25 ns | |
| 메인 메모리(RAM) 참조 | 100 ns | L1 대비 200× |
| Redis/Memcached 조회 (로컬) | ~500 ns–1 μs | 메모리 DB |
| 1 Gbps 네트워크로 1KB 전송 | 10 μs | |
| NVMe SSD 순차 읽기 (4KB) | ~20–100 μs | RAM 대비 ~14–100× (⚠️ 구버전 "200×"는 SATA SSD 기준) |
| SSD 랜덤 읽기 | 0.1 ms (100 μs) | |
| 같은 데이터센터 내 RTT | 500 μs (0.5 ms) | 서비스 간 통신 기준선 |
| SATA SSD / HDD 탐색 | 1–10 ms | HDD는 10 ms |
| 서울–도쿄 패킷 왕복 | ~30–40 ms | 아시아 리전 간 |
| 서울–미국 서부 패킷 왕복 | ~150 ms | 대륙간 기준 |

**⚠️ 팩트체크 수정**: RAM vs 최신 NVMe SSD
- napkin-math 2026년 재측정: RAM 순차 읽기 ~100 GB/s vs NVMe ~7 GB/s → **약 14배** 차이
- "200배" 는 구형 SATA SSD 기준. NVMe 환경에서는 이미 격차 좁혀짐.

---

## 차수 감각 (Order of Magnitude)

```
1 ns        L1 캐시
10 ns       L2 캐시, 단순 로컬 함수 호출
100 ns      RAM 접근
1 μs        Redis 조회, NVMe 소요
100 μs      NVMe SSD, 로컬 처리 상한선
500 μs      같은 DC 서비스 간 RTT  ← MSA 분리 비용 기준선
1 ms        SSD DB 조회
10 ms       HDD 탐색  ← 캐시 도입 ROI 기준선
100–150 ms  대륙간 네트워크
```

**서열은 불변**: 로컬 함수 < RAM < NVMe < DC RTT < SSD DB < HDD DB < 대륙간
(하드웨어가 빨라져도 계층 순서 변하지 않음 — Colin Scott 1990~2025 시각화 확인)

---

## 설계 의사결정 기준

### 1. 캐시 도입 ROI

```
DB 응답 10 ms + Redis 조회 1 μs → 캐시 효과: 10,000배
DB 응답  1 ms + Redis 조회 1 μs → 캐시 효과: 1,000배
DB 응답 0.1 ms (NVMe) + Redis 1 μs → 캐시 효과: 100배
```

판단 기준:
- DB가 HDD 기반이면 캐시 효과 압도적 → 즉시 도입
- NVMe SSD 기반이면 QPS, 캐시 히트율, 운영 복잡도 먼저 계산 후 결정

### 2. MSA 분리 비용

로컬 함수 호출 (~수 ns) → 서비스 간 HTTP 통신 (~500 μs + 직렬화)
= **최소 5만–10만 배** 비용 증가

분리 정당화 조건:
- 호출 빈도가 낮고 (≤ 100 RPS 이하에서 분리 효과 미미)
- 팀 독립 배포 / 장애 격리 / 언어 독립성 필요
- 레이턴시 비용 감수 가능한 비즈니스 경계인 경우

### 3. 고QPS 설계 (목표: 1M QPS)

| 저장소 유형 | 단일 서버 이론 한계 |
|-----------|-----------------|
| RAM 직접 접근 (100 ns) | ~10M ops/s (충분) |
| Redis 조회 (1 μs) | ~1M ops/s (임계선) |
| NVMe SSD DB (100 μs) | ~10K ops/s → 수평 확장 필수 |
| HDD DB (10 ms) | ~100 ops/s → 반드시 캐시 + 샤딩 |

1M QPS 달성 전략:
1. Hot path → 메모리(Redis) 서빙
2. 네트워크 홉 최소화 (서비스 간 호출 배치 처리)
3. SSD DB 직접 노출 금지, 캐시 레이어 필수

### 4. Pingame Server 실측 기준

현재 실측값 없음. 아래 경로 측정 권장:
```
클라이언트 → Colyseus 룸 (WebSocket)
Colyseus → NestJS API (HTTP/gRPC)
NestJS → Redis (TCP)
NestJS → PostgreSQL/MySQL (TCP)
```
목표: 실측 RTT를 이 카드의 기준값과 비교 → 이상치 발견 시 최적화 우선순위 결정

---

## 설계 체크리스트 (제안 전 확인)

- [ ] 병목 지점의 레이턴시가 어느 계층인가? (RAM/SSD/DB/네트워크)
- [ ] 캐시 도입 시 히트율 예상치와 ROI 계산했는가?
- [ ] MSA 분리 시 해당 API의 호출 빈도와 RTT 비용 계산했는가?
- [ ] N+1 쿼리 → 배치로 전환 시 네트워크 왕복 비용 계산했는가?
- [ ] 목표 QPS 대비 각 저장소 계층의 단일 서버 한계 확인했는가?

---

## 참조 원전

| 자료 | 용도 |
|------|------|
| [Norvig: 10년 프로그래밍](https://norvig.com/21-days.html) | 레이턴시 표 원전 (2001~) |
| [Jeff Dean LADIS 2009 PDF](https://research.cs.cornell.edu/ladis2009/talks/dean-keynote-ladis2009.pdf) | DC RTT / SSD 확장판 원전 |
| [jboner gist](https://gist.github.com/jboner/2841832) | 가장 많이 인용되는 정리본 (2012) |
| [Colin Scott Interactive](https://colin-scott.github.io/personal_website/research/interactive_latency.html) | 1990~2020 연도별 변화 시각화 |
| [sirupsen/napkin-math](https://github.com/sirupsen/napkin-math) | 2026년 재측정 실측값 (NVMe 등 최신 하드웨어) |
| [samwho.dev/numbers](https://samwho.dev/numbers/) | 인터랙티브 시각화 (2024~) |
