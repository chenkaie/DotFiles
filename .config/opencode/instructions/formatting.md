# Output Formatting Rules


# Default Table Formatting
When displaying tabular data:
- Use GitHub-style Markdown pipe tables.
- Always wrap tables in fenced code blocks for monospaced alignment.
- Do NOT use box-drawing ASCII borders.
- Keep columns padded for visual alignment.
- Example:
```
  | Col A | Col B | Col C |
  |-------|-------|-------|
  | foo   | bar   | baz   |
  | foo1  | bar1  | baz1  |
```


# Other Table Formatting Options
```
- Table 0

| Rank | PID  | User   | VSZ    | %MEM   | Command                          |
|------|------|--------|--------|--------|----------------------------------|
| 1    | 729  | root   | 1.7G   | 135.1% | /usr/bin/framework_app           |
| 2    | 600  | root   | 805M   | 64.0%  | /usr/sbin/collectd               |
| 3    | 634  | root   | 540M   | 42.9%  | /usr/bin/deploy-service          |
| 4    | 776  | root   | 432M   | 34.3%  | /usr/bin/health_monitor          |
| 5    | 564  | root   | 312M   | 24.8%  | /usr/sbin/NetworkManager         |
| 6    | 636  | root   | 292M   | 23.2%  | /usr/bin/mqtt_bridge             |
| 7    | 648  | root   | 218M   | 17.3%  | /usr/bin/registration_service    |
| 8    | 454  | pulse  | 174M   | 13.8%  | /usr/bin/pulseaudio              |
| 9    | 466  | root   | 138M   | 10.9%  | /usr/bin/audio-dsp-server        |
| 10   | 595  | root   | 137M   | 10.9%  | /usr/bin/network_manager_agent   |

- Table 1
+---+----------------------------------+---------+------------------------+----------------+
|   |                A                 |    B    |           C            |       D        |
+---+----------------------------------+---------+------------------------+----------------+
| 1 | Col1                             | Col2    | Col3                   | Numeric Column |
| 2 | Value 1                          | Value 2 | 123                    | 10.0           |
| 3 | Separate                         | cols    | with a tab or 4 spaces | -2,027.1       |
| 4 | This is a row with only one cell |         |                        |                |
+---+----------------------------------+---------+------------------------+----------------+

- Table 2

 === ================================== ========= ======================== ================
                     A                      B                C                    D
 === ================================== ========= ======================== ================
  1   Col1                               Col2      Col3                     Numeric Column
  2   Value 1                            Value 2   123                      10.0
  3   Separate                           cols      with a tab or 4 spaces   -2,027.1
  4   This is a row with only one cell
 === ================================== ========= ======================== ================

- Table 3
.---.----------------------------------.---------.------------------------.----------------.
|   |                A                 |    B    |           C            |       D        |
:---+----------------------------------+---------+------------------------+----------------:
| 1 | Col1                             | Col2    | Col3                   | Numeric Column |
:---+----------------------------------+---------+------------------------+----------------:
| 2 | Value 1                          | Value 2 | 123                    | 10.0           |
:---+----------------------------------+---------+------------------------+----------------:
| 3 | Separate                         | cols    | with a tab or 4 spaces | -2,027.1       |
:---+----------------------------------+---------+------------------------+----------------:
| 4 | This is a row with only one cell |         |                        |                |
'---'----------------------------------'---------'------------------------'----------------'

- Table 4
┌───┬──────────────────────────────────┬─────────┬────────────────────────┬────────────────┐
│   │                A                 │    B    │           C            │       D        │
├───┼──────────────────────────────────┼─────────┼────────────────────────┼────────────────┤
│ 1 │ Col1                             │ Col2    │ Col3                   │ Numeric Column │
│ 2 │ Value 1                          │ Value 2 │ 123                    │ 10.0           │
│ 3 │ Separate                         │ cols    │ with a tab or 4 spaces │ -2,027.1       │
│ 4 │ This is a row with only one cell │         │                        │                │
└───┴──────────────────────────────────┴─────────┴────────────────────────┴────────────────┘

- Table 5
Header
───────────────────────────────────────────────────────────────────
CPU:   0.0% usr   0.0% sys   0.0% nic   100% idle   0.0% io
Load:  1.10 (1m)  1.07 (5m)  1.08 (15m)
───────────────────────────────────────────────────────────────────
Rank   PID    %CPU   %MEM     VSZ   Process
────   ────   ────   ─────   ─────  ───────────────────────────────
  1     729   0.0%   135.1%   1.7G  /usr/bin/framework_app
  2     600   0.0%    64.0%   805M  /usr/sbin/collectd
  3     634   0.0%    42.9%   540M  /usr/bin/deploy-service
  4     776   0.0%    34.3%   432M  /usr/bin/health_monitor
  5     564   0.0%    24.8%   312M  /usr/sbin/NetworkManager
  6     636   0.0%    23.2%   292M  /usr/bin/mqtt_bridge
  7     648   0.0%    17.3%   218M  /usr/bin/registration_service
  8     454   0.0%    13.8%   174M  /usr/bin/pulseaudio
  9     466   0.0%    10.9%   138M  /usr/bin/audio-dsp-server
 10     595   0.0%    10.9%   137M  /usr/bin/network_manager_agent

----------------------------------------------------------------------------------------------------
- Misc ASCII shapes
                                                      ┌────────┐         ***
                  ╱‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾╱   ╱‾‾‾‾‾‾‾‾‾╱╲    │callout │     ****   ****     ╱‾‾‾‾‾‾‾‾‾╲
 ┌──────────┐    ╱               ╱   │         │  │   └────────┘  ***  diamond  *** ╱           ╲
 │rectangle │   ╱ parallelogram ╱    │   queue │  │        │ ╱      ****     ****   ╲  hexagon  ╱
 │          │  ╱_______________╱      ╲________ ╲╱         │╱           *****        ╲_________╱
 └──────────┘
       │                 │                  │              │              │                │
       ▼                 ▼                  ▼              ▼              │                ▼
  ┌─────────┐      ┌──────────┐        ┌────┐        ╱‾‾‾‾‾‾‾‾‾‾‾╱        ▼          ┌☁─────────┐
  │         │      │ document │        │    └────┐  ╱           ╱    ┌⬭────────┐     │          │
  │ square  │      │     .-`-.│        │ package │ │ stored_data     │  oval   │     │  cloud   │
  │         │       `-.-`              └─────────┘  ╲           ╲    │         │     │          │
  │         │                                        ╲___________╲   └─────────┘     │          │
  └─────────┘            │                  │              │              │          └──────────┘
       │                 │                  │              │              │
       ▼                 ▼                  ▼              ▼              │
   ┌─────┐          .-‾‾‾‾-.          ╲‾‾‾‾‾‾‾ ╲         ╱‾‾╲             ▼
   │     ╲┐        │╲-____-╱│          ╲        ╲        ╲__╱        ┌⬭────────┐
   │ page │        │        │           ╲        ╲      ╱‾‾‾‾╲       │         │
   │      │        │        │           ╱ step   ╱      ‾‾‾‾‾‾       │ circle  │
   └──────┘        │cylinder│          ╱        ╱       person       │         │
                   │        │         ╱_______ ╱                     │         │
                    ╲-____-╱                                         └─────────┘
```

<!--
   -- Always use aligned ASCII/monospace formatting inside code blocks
   -- Never use raw markdown table syntax (|---|)
   -- Use fixed-width columns with proper spacing
   -- Use simple alignment characters (spaces, dashes) or box-drawing characters (─, │, ┌, ┐) for clean terminal display
   -- Or choose from below ascii shpae if that fits your needs:
-->

