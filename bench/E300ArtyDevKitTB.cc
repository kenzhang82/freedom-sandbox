#include <stdint.h>
#include <signal.h>
#include <fstream>

#include "verilated_vcd_c.h"
#include "VE300ArtyDevKitChip.h"

using namespace std;

/* Current simulation time
 * This is a 64-bit integer to reduce wrap over issues and
 * allow modulus.  You can also use a double, if you wish.
 */
vluint64_t main_time = 0;
static bool done;

/* Called by $time in Verilog
 * converts to double, to match
 * what SystemC does
 */
double sc_time_stamp (void)
{
	return main_time;
}

void INThandler(int signal)
{
	printf("\nCaught ctrl-c\n");
	done = true;
}

int main(int argc, char **argv, char **env)
{
	Verilated::commandArgs(argc, argv);
	VE300ArtyDevKitChip *top = new VE300ArtyDevKitChip("VE300ArtyDevKitChip_inst");

	// Tracing (vcd)
	VerilatedVcdC * tfp = NULL;
	const char *vcd = Verilated::commandArgsPlusMatch("vcd=");
	if (vcd[0])
	{
		const char *vcd_name = strchr(vcd, '=') + 1;
		Verilated::traceEverOn(true);
		tfp = new VerilatedVcdC;
		top->trace(tfp, 99);
		tfp->open(vcd_name);
	}

	// Maximum timeout
	vluint64_t timeout = 0;
	const char *arg_timeout = Verilated::commandArgsPlusMatch("timeout=");
	if (arg_timeout[0])
	{
		timeout = atoi(arg_timeout+9);
	}

	signal(SIGINT, INThandler);

	// Stimulus
	top->cpu_clock  = 0;
    top->cpu_rst_n  = 0;
    top->jtag_rst_n = 0;
	while (!(done || Verilated::gotFinish()))
    {
		top->jtag_rst_n = main_time > 200;
		top->cpu_rst_n  = main_time > 400;
		top->eval();

		if (tfp)
		{
			tfp->dump(main_time);
		}

		if (timeout && (main_time >= timeout))
		{
			printf("Timeout: Exiting at time %lu\n", main_time);
			done = true;
		}

		top->cpu_clock  = !top->cpu_clock;
		main_time += 7.5;
	}
	if (tfp) tfp->close();
	delete top;
	exit(0);
}