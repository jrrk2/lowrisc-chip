#include "uart.h"

static const uint64_t uart_base[2] = {UARTBase,BTBase};

#define _write_reg_u8(addr, value) *((volatile uint8_t *)addr) = value

#define _read_reg_u8(addr) (*(volatile uint8_t *)addr)

#define _is_transmit_empty(ch) (read_line_status(ch) & 0x20)

#define _write_serial(ch, a)               \
    while (_is_transmit_empty(ch) == 0) {}; \
    write_reg_u8(UART_THR(ch), a);          \

#define _is_data_ready(ch) (read_line_status(ch) & 0x1)

void write_reg_u8(uintptr_t addr, uint8_t value) { _write_reg_u8(addr, value); }
uint8_t read_reg_u8(uintptr_t addr) { return _read_reg_u8(addr); }
uint8_t read_line_status(int ch) { return _read_reg_u8(UART_LINE_STATUS(ch)); }
int is_transmit_empty(int ch) { return _is_transmit_empty(ch); }
void write_serial(int ch, char a) { _write_serial(ch, a); }
int read_serial(int ch) { return _is_data_ready(ch) ? read_reg_u8(UART_RBR(ch)) : -1; }

void init_uart(int ch, uint16_t baud)
{
  _write_reg_u8(UART_INTERRUPT_ENABLE(ch), 0x00); // Disable all interrupts
  _write_reg_u8(UART_LINE_CONTROL(ch), 0x80);     // Enable DLAB (set baud rate divisor)
  _write_reg_u8(UART_DLAB_LSB(ch), baud & 0xFF);  // Set divisor to (lo byte) e.g. 27 => 50M/16/27 => 115200 baud
  _write_reg_u8(UART_DLAB_MSB(ch), baud >> 8);    //                (hi byte) (0.4% speed error at 115740 baud)
  _write_reg_u8(UART_FIFO_CONTROL(ch), 0xE7);     // Enable FIFO64, clear them, with 14-byte threshold
  _write_reg_u8(UART_LINE_CONTROL(ch), 0x03);     // 8 bits, no parity, one stop bit
  _write_reg_u8(UART_MODEM_CONTROL(ch), 0x20);    // Autoflow mode
}

void print_uart(int ch, const char *str)
{
    const char *cur = &str[0];
    while (*cur != '\0')
    {
      _write_serial(ch, (uint8_t)*cur);
        ++cur;
    }
}

const uint8_t bin_to_hex_table[16] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};

void bin_to_hex(uint8_t inp, uint8_t res[2])
{
    res[1] = bin_to_hex_table[inp & 0xf];
    res[0] = bin_to_hex_table[(inp >> 4) & 0xf];
    return;
}

void print_uart_short(int ch, uint16_t addr)
{
    int i;
    for (i = 1; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        bin_to_hex(cur, hex);
        write_serial(ch, hex[0]);
        write_serial(ch, hex[1]);
    }
}

void print_uart_int(int ch, uint32_t addr)
{
    int i;
    for (i = 3; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        bin_to_hex(cur, hex);
        write_serial(ch, hex[0]);
        write_serial(ch, hex[1]);
    }
}

void print_uart_addr(int ch, uint64_t addr)
{
    int i;
    for (i = 7; i > -1; i--)
    {
        uint8_t cur = (addr >> (i * 8)) & 0xff;
        uint8_t hex[2];
        bin_to_hex(cur, hex);
        write_serial(ch, hex[0]);
        write_serial(ch, hex[1]);
    }
}

void print_uart_byte(int ch, uint8_t byte)
{
    uint8_t hex[2];
    bin_to_hex(byte, hex);
    write_serial(ch, hex[0]);
    write_serial(ch, hex[1]);
}
