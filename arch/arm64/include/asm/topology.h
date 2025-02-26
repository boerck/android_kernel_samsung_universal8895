#ifndef __ASM_TOPOLOGY_H
#define __ASM_TOPOLOGY_H

#include <linux/cpumask.h>

struct cpu_topology {
	int thread_id;
	int core_id;
	int cluster_id;
	cpumask_t thread_sibling;
	cpumask_t core_sibling;
};

extern struct cpu_topology cpu_topology[NR_CPUS];

#define topology_physical_package_id(cpu)	(cpu_topology[cpu].cluster_id)
#define topology_core_id(cpu)		(cpu_topology[cpu].core_id)
#define topology_core_cpumask(cpu)	(&cpu_topology[cpu].core_sibling)
#define topology_sibling_cpumask(cpu)	(&cpu_topology[cpu].thread_sibling)

void init_cpu_topology(void);
int get_current_cpunum(void);
void store_cpu_topology(unsigned int cpuid);
const struct cpumask *cpu_coregroup_mask(int cpu);

struct sched_domain;
#ifdef CONFIG_CPU_FREQ
#define arch_scale_freq_capacity cpufreq_scale_freq_capacity
extern unsigned long cpufreq_scale_freq_capacity(struct sched_domain *sd, int cpu);
#define arch_scale_max_freq_capacity cpufreq_scale_max_freq_capacity
extern unsigned long cpufreq_scale_max_freq_capacity(struct sched_domain *sd, int cpu);
#define arch_scale_min_freq_capacity cpufreq_scale_min_freq_capacity
extern unsigned long cpufreq_scale_min_freq_capacity(struct sched_domain *sd, int cpu);
#endif
#define arch_scale_cpu_capacity scale_cpu_capacity
extern unsigned long scale_cpu_capacity(struct sched_domain *sd, int cpu);

#include <asm-generic/topology.h>

#endif /* _ASM_ARM_TOPOLOGY_H */
