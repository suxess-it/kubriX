
For OSS Maintainers: VEX Notice
--------------------------------
If you're an OSS maintainer and Trivy has detected vulnerabilities in your project that you believe are not actually exploitable, consider issuing a VEX (Vulnerability Exploitability eXchange) statement.
VEX allows you to communicate the actual status of vulnerabilities in your project, improving security transparency and reducing false positives for your users.
Learn more and start using VEX: https://aquasecurity.github.io/trivy/v0.57/docs/supply-chain/vex/repo#publishing-vex-documents

To disable this notice, set the TRIVY_DISABLE_VEX_NOTICE environment variable.


ghcr.io/suxess-it/sx-backstage:v1.32.5 (debian 12.7)
====================================================
Total: 114 (HIGH: 113, CRITICAL: 1)

┌───────────────────────┬────────────────┬──────────┬────────┬───────────────────┬──────────────────┬──────────────────────────────────────────────────────────────┐
│        Library        │ Vulnerability  │ Severity │ Status │ Installed Version │  Fixed Version   │                            Title                             │
├───────────────────────┼────────────────┼──────────┼────────┼───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ libpython3.11         │ CVE-2024-6232  │ HIGH     │ fixed  │ 3.11.2-6+deb12u3  │ 3.11.2-6+deb12u4 │ python: cpython: tarfile: ReDos via excessive backtracking   │
│                       │                │          │        │                   │                  │ while parsing header values                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-6232                    │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ libpython3.11-dev     │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ libpython3.11-minimal │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ libpython3.11-stdlib  │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ libsqlite3-0          │ CVE-2023-7104  │          │        │ 3.40.1-2          │ 3.40.1-2+deb12u1 │ sqlite: heap-buffer-overflow at sessionfuzz                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-7104                    │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ libsqlite3-dev        │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┼────────────────┼──────────┤        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ linux-libc-dev        │ CVE-2024-47685 │ CRITICAL │        │ 6.1.112-1         │ 6.1.115-1        │ kernel: netfilter: nf_reject_ipv6: fix                       │
│                       │                │          │        │                   │                  │ nf_reject_ip6_tcphdr_put()                                   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47685                   │
│                       ├────────────────┼──────────┤        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2023-52812 │ HIGH     │        │                   │ 6.1.119-1        │ kernel: drm/amd: check num of link levels when update pcie   │
│                       │                │          │        │                   │                  │ param                                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2023-52812                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-26952 │          │        │                   │                  │ kernel: ksmbd: fix potencial out-of-bounds when buffer       │
│                       │                │          │        │                   │                  │ offset is invalid                                            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-26952                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-41071 │          │        │                   │ 6.1.115-1        │ kernel: wifi: mac80211: Avoid address calculations via out   │
│                       │                │          │        │                   │                  │ of bounds array indexing...                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-41071                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-44949 │          │        │                   │ 6.1.119-1        │ kernel: parisc: fix a possible DMA corruption                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-44949                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47682 │          │        │                   │ 6.1.115-1        │ kernel: scsi: sd: Fix off-by-one error in                    │
│                       │                │          │        │                   │                  │ sd_read_block_characteristics()                              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47682                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47686 │          │        │                   │                  │ kernel: ep93xx: clock: Fix off by one in                     │
│                       │                │          │        │                   │                  │ ep93xx_div_recalc_rate()                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47686                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47695 │          │        │                   │                  │ kernel: RDMA/rtrs-clt: Reset cid to con_num - 1 to stay in   │
│                       │                │          │        │                   │                  │ bounds...                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47695                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47696 │          │        │                   │                  │ kernel: RDMA/iwcm: Fix                                       │
│                       │                │          │        │                   │                  │ WARNING:at_kernel/workqueue.c:#check_flush_dependency        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47696                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47697 │          │        │                   │                  │ kernel: drivers: media: dvb-frontends/rtl2830: fix an        │
│                       │                │          │        │                   │                  │ out-of-bounds write error                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47697                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47698 │          │        │                   │                  │ kernel: drivers: media: dvb-frontends/rtl2832: fix an        │
│                       │                │          │        │                   │                  │ out-of-bounds write error                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47698                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47701 │          │        │                   │                  │ kernel: ext4: avoid OOB when system.data xattr changes       │
│                       │                │          │        │                   │                  │ underneath the filesystem                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47701                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47718 │          │        │                   │                  │ kernel: wifi: rtw88: always wait for both firmware loading   │
│                       │                │          │        │                   │                  │ attempts                                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47718                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47723 │          │        │                   │                  │ kernel: jfs: fix out-of-bounds in dbNextAG() and diAlloc()   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47723                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47727 │          │        │                   │                  │ kernel: x86/tdx: Fix "in-kernel MMIO" check                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47727                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47730 │          │        │                   │                  │ kernel: crypto: hisilicon/qm - inject error before stopping  │
│                       │                │          │        │                   │                  │ queue                                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47730                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47742 │          │        │                   │                  │ kernel: firmware_loader: Block path traversal                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47742                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47747 │          │        │                   │                  │ kernel: net: seeq: Fix use after free vulnerability in       │
│                       │                │          │        │                   │                  │ ether3 Driver Due...                                         │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47747                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47748 │          │        │                   │                  │ kernel: vhost_vdpa: assign irq bypass producer token         │
│                       │                │          │        │                   │                  │ correctly                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47748                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47750 │          │        │                   │                  │ kernel: RDMA/hns: Fix Use-After-Free of rsv_qp on HIP08      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47750                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47751 │          │        │                   │                  │ kernel: PCI: kirin: Fix buffer overflow in                   │
│                       │                │          │        │                   │                  │ kirin_pcie_parse_port()                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47751                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-47757 │          │        │                   │                  │ kernel: nilfs2: fix potential oob read in                    │
│                       │                │          │        │                   │                  │ nilfs_btree_check_delete()                                   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-47757                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49852 │          │        │                   │                  │ kernel: scsi: elx: libefc: Fix potential use after free in   │
│                       │                │          │        │                   │                  │ efc_nport_vport_del()                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49852                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49853 │          │        │                   │                  │ kernel: firmware: arm_scmi: Fix double free in OPTEE         │
│                       │                │          │        │                   │                  │ transport                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49853                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49854 │          │        │                   │                  │ kernel: block, bfq: fix uaf for accessing waker_bfqq after   │
│                       │                │          │        │                   │                  │ splitting                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49854                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49855 │          │        │                   │                  │ kernel: nbd: fix race between timeout and normal completion  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49855                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49860 │          │        │                   │                  │ kernel: ACPI: sysfs: validate return type of _STR method     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49860                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49882 │          │        │                   │                  │ kernel: ext4: fix double brelse() the buffer of the extents  │
│                       │                │          │        │                   │                  │ path                                                         │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49882                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49883 │          │        │                   │                  │ kernel: ext4: aovid use-after-free in                        │
│                       │                │          │        │                   │                  │ ext4_ext_insert_extent()                                     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49883                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49884 │          │        │                   │                  │ kernel: ext4: fix slab-use-after-free in                     │
│                       │                │          │        │                   │                  │ ext4_split_extent_at()                                       │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49884                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49889 │          │        │                   │                  │ kernel: ext4: avoid use-after-free in ext4_ext_show_leaf()   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49889                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49894 │          │        │                   │                  │ kernel: drm/amd/display: Fix index out of bounds in degamma  │
│                       │                │          │        │                   │                  │ hardware format translation...                               │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49894                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49895 │          │        │                   │                  │ kernel: drm/amd/display: Fix index out of bounds in DCN30    │
│                       │                │          │        │                   │                  │ degamma hardware format...                                   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49895                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49900 │          │        │                   │                  │ kernel: jfs: Fix uninit-value access of new_ea in ea_buffer  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49900                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49903 │          │        │                   │                  │ kernel: jfs: Fix uaf in dbFreeBits                           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49903                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49924 │          │        │                   │                  │ kernel: fbdev: pxafb: Fix possible use after free in         │
│                       │                │          │        │                   │                  │ pxafb_task()                                                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49924                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49930 │          │        │                   │                  │ kernel: wifi: ath11k: fix array out-of-bound access in SoC   │
│                       │                │          │        │                   │                  │ stats                                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49930                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49936 │          │        │                   │                  │ kernel: net/xen-netback: prevent UAF in xenvif_flush_hash()  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49936                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49950 │          │        │                   │ 6.1.119-1        │ kernel: Bluetooth: L2CAP: Fix uaf in l2cap_connect           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49950                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49960 │          │        │                   │                  │ kernel: ext4: fix timer use-after-free on failed mount       │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49960                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49966 │          │        │                   │ 6.1.115-1        │ kernel: ocfs2: cancel dqi_sync_work before freeing oinfo     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49966                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49967 │          │        │                   │                  │ kernel: ext4: no need to continue when the number of entries │
│                       │                │          │        │                   │                  │ is...                                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49967                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49969 │          │        │                   │                  │ kernel: drm/amd/display: Fix index out of bounds in DCN30    │
│                       │                │          │        │                   │                  │ color transformation                                         │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49969                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49981 │          │        │                   │                  │ kernel: media: venus: fix use after free bug in venus_remove │
│                       │                │          │        │                   │                  │ due to...                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49981                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49982 │          │        │                   │                  │ kernel: aoe: fix the potential use-after-free problem in     │
│                       │                │          │        │                   │                  │ more places                                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49982                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49983 │          │        │                   │                  │ kernel: ext4: drop ppath from ext4_ext_replay_update_ex() to │
│                       │                │          │        │                   │                  │ avoid double-free                                            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49983                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49986 │          │        │                   │ 6.1.119-1        │ kernel: platform/x86: x86-android-tablets: Fix use after     │
│                       │                │          │        │                   │                  │ free on platform_device_register() errors                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49986                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49991 │          │        │                   │                  │ kernel: drm/amdkfd: amdkfd_free_gtt_mem clear the correct    │
│                       │                │          │        │                   │                  │ pointer                                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49991                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49992 │          │        │                   │ 6.1.115-1        │ kernel: drm/stm: Avoid use-after-free issues with crtc and   │
│                       │                │          │        │                   │                  │ plane                                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49992                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49995 │          │        │                   │                  │ kernel: tipc: guard against string buffer overrun            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49995                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-49997 │          │        │                   │                  │ kernel: net: ethernet: lantiq_etop: fix memory disclosure    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-49997                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50007 │          │        │                   │                  │ kernel: ALSA: asihpi: Fix potential OOB array access         │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50007                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50033 │          │        │                   │                  │ kernel: slip: make slhc_remember() more robust against       │
│                       │                │          │        │                   │                  │ malicious packets                                            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50033                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50035 │          │        │                   │                  │ kernel: ppp: fix ppp_async_encode() illegal access           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50035                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50036 │          │        │                   │ 6.1.119-1        │ kernel: net: do not delay dst_entries_add() in dst_release() │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50036                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50059 │          │        │                   │ 6.1.115-1        │ kernel: ntb: ntb_hw_switchtec: Fix use after free            │
│                       │                │          │        │                   │                  │ vulnerability in switchtec_ntb_remove due to...              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50059                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50067 │          │        │                   │ 6.1.119-1        │ kernel: uprobe: avoid out-of-bounds memory access of         │
│                       │                │          │        │                   │                  │ fetching args                                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50067                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50073 │          │        │                   │ 6.1.115-1        │ kernel: tty: n_gsm: Fix use-after-free in gsm_cleanup_mux    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50073                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50074 │          │        │                   │                  │ kernel: parport: Proper fix for array out-of-bounds access   │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50074                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50083 │          │        │                   │                  │ kernel: tcp: fix mptcp DSS corruption due to large pmtu xmit │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50083                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50086 │          │        │                   │                  │ kernel: ksmbd: fix user-after-free from session log off      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50086                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50088 │          │        │                   │                  │ kernel: btrfs: fix uninitialized pointer free in             │
│                       │                │          │        │                   │                  │ add_inode_ref()                                              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50088                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50115 │          │        │                   │                  │ kernel: KVM: nSVM: Ignore nCR3[4:0] when loading PDPTEs from │
│                       │                │          │        │                   │                  │ memory                                                       │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50115                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50124 │          │        │                   │                  │ kernel: Bluetooth: ISO: Fix UAF on iso_sock_timeout          │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50124                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50125 │          │        │                   │                  │ kernel: Bluetooth: SCO: Fix UAF on sco_sock_timeout          │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50125                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50126 │          │        │                   │ 6.1.119-1        │ kernel: net: sched: use RCU read-side critical section in    │
│                       │                │          │        │                   │                  │ taprio_dump()                                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50126                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50127 │          │        │                   │ 6.1.115-1        │ kernel: net: sched: fix use-after-free in taprio_change()    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50127                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50128 │          │        │                   │                  │ kernel: net: wwan: fix global oob in wwan_rtnl_policy        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50128                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50131 │          │        │                   │                  │ kernel: tracing: Consider the NULL character when validating │
│                       │                │          │        │                   │                  │ the event length                                             │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50131                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50143 │          │        │                   │                  │ kernel: udf: fix uninit-value use in udf_get_fileshortad     │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50143                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50150 │          │        │                   │                  │ kernel: usb: typec: altmode should keep reference to parent  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50150                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50151 │          │        │                   │                  │ kernel: smb: client: fix OOBs when building SMB2_IOCTL       │
│                       │                │          │        │                   │                  │ request                                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50151                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50154 │          │        │                   │                  │ kernel: tcp/dccp: Don&#39;t use timer_pending() in           │
│                       │                │          │        │                   │                  │ reqsk_queue_unlink().                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50154                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50155 │          │        │                   │                  │ kernel: netdevsim: use cond_resched() in                     │
│                       │                │          │        │                   │                  │ nsim_dev_trap_report_work()                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50155                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50180 │          │        │                   │                  │ kernel: fbdev: sisfb: Fix strbuf array overflow              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50180                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50186 │          │        │                   │                  │ kernel: net: explicitly clear the sk pointer, when           │
│                       │                │          │        │                   │                  │ pf-&gt;create fails                                          │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50186                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50193 │          │        │                   │                  │ kernel: x86/entry_32: Clear CPU buffers after register       │
│                       │                │          │        │                   │                  │ restore in NMI return                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50193                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50209 │          │        │                   │                  │ kernel: RDMA/bnxt_re: Add a check for memory allocation      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50209                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50215 │          │        │                   │ 6.1.119-1        │ kernel: nvmet-auth: assign dh_key to NULL after              │
│                       │                │          │        │                   │                  │ kfree_sensitive                                              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50215                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50230 │          │        │                   │                  │ kernel: nilfs2: fix kernel bug due to missing clearing of    │
│                       │                │          │        │                   │                  │ checked flag...                                              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50230                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50234 │          │        │                   │                  │ kernel: wifi: iwlegacy: Clear stale interrupts before        │
│                       │                │          │        │                   │                  │ resuming device                                              │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50234                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50235 │          │        │                   │                  │ kernel: wifi: cfg80211: clear wdev->cqm_config pointer on    │
│                       │                │          │        │                   │                  │ free                                                         │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50235                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50242 │          │        │                   │                  │ kernel: fs/ntfs3: Additional check in ntfs_file_release      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50242                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50247 │          │        │                   │                  │ kernel: fs/ntfs3: Check if more than chunk-size bytes are    │
│                       │                │          │        │                   │                  │ written                                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50247                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50250 │          │        │                   │                  │ kernel: fsdax: dax_unshare_iter needs to copy entire blocks  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50250                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50257 │          │        │                   │                  │ kernel: netfilter: Fix use-after-free in get_info()          │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50257                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50261 │          │        │                   │                  │ kernel: macsec: Fix use-after-free while sending the         │
│                       │                │          │        │                   │                  │ offloading packet                                            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50261                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50262 │          │        │                   │                  │ kernel: bpf: Fix out-of-bounds write in trie_get_next_key()  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50262                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50264 │          │        │                   │                  │ kernel: vsock/virtio: Initialization of the dangling pointer │
│                       │                │          │        │                   │                  │ occurring in vsk->trans                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50264                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50267 │          │        │                   │                  │ kernel: USB: serial: io_edgeport: fix use after free in      │
│                       │                │          │        │                   │                  │ debug printk                                                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50267                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50268 │          │        │                   │                  │ kernel: usb: typec: fix potential out of bounds in           │
│                       │                │          │        │                   │                  │ ucsi_ccg_update_set_new_cam_cmd()                            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50268                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50269 │          │        │                   │                  │ kernel: usb: musb: sunxi: Fix accessing an released usb phy  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50269                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50276 │          │        │                   │                  │ kernel: net: vertexcom: mse102x: Fix possible double free of │
│                       │                │          │        │                   │                  │ TX skb                                                       │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50276                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50278 │          │        │                   │                  │ kernel: dm cache: fix potential out-of-bounds access on the  │
│                       │                │          │        │                   │                  │ first resume                                                 │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50278                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50279 │          │        │                   │                  │ kernel: dm cache: fix out-of-bounds access to the dirty      │
│                       │                │          │        │                   │                  │ bitset when resizing...                                      │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50279                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50282 │          │        │                   │                  │ kernel: drm/amdgpu: add missing size check in                │
│                       │                │          │        │                   │                  │ amdgpu_debugfs_gprwave_read()                                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50282                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50283 │          │        │                   │                  │ kernel: ksmbd: fix slab-use-after-free in                    │
│                       │                │          │        │                   │                  │ smb3_preauth_hash_rsp                                        │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50283                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50286 │          │        │                   │                  │ kernel: ksmbd: fix slab-use-after-free in                    │
│                       │                │          │        │                   │                  │ ksmbd_smb2_session_create                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50286                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-50301 │          │        │                   │                  │ kernel: security/keys: fix slab-out-of-bounds in             │
│                       │                │          │        │                   │                  │ key_task_permission                                          │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-50301                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-53057 │          │        │                   │                  │ kernel: net/sched: stop qdisc_tree_reduce_backlog on         │
│                       │                │          │        │                   │                  │ TC_H_ROOT                                                    │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-53057                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-53059 │          │        │                   │                  │ kernel: wifi: iwlwifi: mvm: Fix response handling in         │
│                       │                │          │        │                   │                  │ iwl_mvm_send_recovery_cmd()                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-53059                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-53061 │          │        │                   │                  │ kernel: media: s5p-jpeg: prevent buffer overflows            │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-53061                   │
│                       ├────────────────┤          │        │                   │                  ├──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-53082 │          │        │                   │                  │ kernel: virtio_net: Add hash_key_length check                │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-53082                   │
│                       ├────────────────┤          │        │                   ├──────────────────┼──────────────────────────────────────────────────────────────┤
│                       │ CVE-2024-8805  │          │        │                   │ 6.1.115-1        │ BlueZ HID over GATT Profile Improper Access Control Remote   │
│                       │                │          │        │                   │                  │ Code Execut ......                                           │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-8805                    │
├───────────────────────┼────────────────┤          │        ├───────────────────┼──────────────────┼──────────────────────────────────────────────────────────────┤
│ python3.11            │ CVE-2024-6232  │          │        │ 3.11.2-6+deb12u3  │ 3.11.2-6+deb12u4 │ python: cpython: tarfile: ReDos via excessive backtracking   │
│                       │                │          │        │                   │                  │ while parsing header values                                  │
│                       │                │          │        │                   │                  │ https://avd.aquasec.com/nvd/cve-2024-6232                    │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ python3.11-dev        │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ python3.11-minimal    │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
├───────────────────────┤                │          │        │                   │                  │                                                              │
│ python3.11-venv       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
│                       │                │          │        │                   │                  │                                                              │
└───────────────────────┴────────────────┴──────────┴────────┴───────────────────┴──────────────────┴──────────────────────────────────────────────────────────────┘

Node.js (node-pkg)
==================
Total: 5 (HIGH: 2, CRITICAL: 3)

┌──────────────────────────────┬────────────────┬──────────┬────────┬───────────────────┬───────────────┬───────────────────────────────────────────────────────────┐
│           Library            │ Vulnerability  │ Severity │ Status │ Installed Version │ Fixed Version │                           Title                           │
├──────────────────────────────┼────────────────┼──────────┼────────┼───────────────────┼───────────────┼───────────────────────────────────────────────────────────┤
│ cross-spawn (package.json)   │ CVE-2024-21538 │ HIGH     │ fixed  │ 7.0.3             │ 7.0.5, 6.0.6  │ cross-spawn: regular expression denial of service         │
│                              │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-21538                │
├──────────────────────────────┼────────────────┼──────────┤        ├───────────────────┼───────────────┼───────────────────────────────────────────────────────────┤
│ jsonpath-plus (package.json) │ CVE-2024-21534 │ CRITICAL │        │ 7.2.0             │ 10.0.7        │ jsonpath-plus: Remote Code Execution in jsonpath-plus via │
│                              │                │          │        │                   │               │ Improper Input Sanitization                               │
│                              │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-21534                │
├──────────────────────────────┼────────────────┤          │        ├───────────────────┼───────────────┼───────────────────────────────────────────────────────────┤
│ mysql2 (package.json)        │ CVE-2024-21508 │          │        │ 2.3.3             │ 3.9.4         │ mysql2: Remote Code Execution                             │
│                              │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-21508                │
│                              ├────────────────┤          │        │                   ├───────────────┼───────────────────────────────────────────────────────────┤
│                              │ CVE-2024-21511 │          │        │                   │ 3.9.7         │ mysql2: Arbitrary Code Injection due to improper          │
│                              │                │          │        │                   │               │ sanitization of the timezone parameter...                 │
│                              │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-21511                │
│                              ├────────────────┼──────────┤        │                   ├───────────────┼───────────────────────────────────────────────────────────┤
│                              │ CVE-2024-21512 │ HIGH     │        │                   │ 3.9.8         │ mysql2: vulnerable to Prototype Pollution due to improper │
│                              │                │          │        │                   │               │ user input sanitization                                   │
│                              │                │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-21512                │
└──────────────────────────────┴────────────────┴──────────┴────────┴───────────────────┴───────────────┴───────────────────────────────────────────────────────────┘

Python (python-pkg)
===================
Total: 1 (HIGH: 1, CRITICAL: 0)

┌───────────────────────┬───────────────┬──────────┬────────┬───────────────────┬───────────────┬─────────────────────────────────────────────────────┐
│        Library        │ Vulnerability │ Severity │ Status │ Installed Version │ Fixed Version │                        Title                        │
├───────────────────────┼───────────────┼──────────┼────────┼───────────────────┼───────────────┼─────────────────────────────────────────────────────┤
│ setuptools (METADATA) │ CVE-2024-6345 │ HIGH     │ fixed  │ 66.1.1            │ 70.0.0        │ pypa/setuptools: Remote code execution via download │
│                       │               │          │        │                   │               │ functions in the package_index module in...         │
│                       │               │          │        │                   │               │ https://avd.aquasec.com/nvd/cve-2024-6345           │
└───────────────────────┴───────────────┴──────────┴────────┴───────────────────┴───────────────┴─────────────────────────────────────────────────────┘
