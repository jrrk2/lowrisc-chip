#pragma once

#include <stdint.h>
#include "ariane.h"

#define UART_RBR(ch) uart_base[ch] + 0
#define UART_THR(ch) uart_base[ch] + 0
#define UART_INTERRUPT_ENABLE(ch) uart_base[ch] + 4
#define UART_INTERRUPT_IDENT(ch) uart_base[ch] + 8
#define UART_FIFO_CONTROL(ch) uart_base[ch] + 8
#define UART_LINE_CONTROL(ch) uart_base[ch] + 12
#define UART_MODEM_CONTROL(ch) uart_base[ch] + 16
#define UART_LINE_STATUS(ch) uart_base[ch] + 20
#define UART_MODEM_STATUS(ch) uart_base[ch] + 24
#define UART_DLAB_LSB(ch) uart_base[ch] + 0
#define UART_DLAB_MSB(ch) uart_base[ch] + 4

void init_uart(int ch, uint16_t baud);

void print_uart(int ch, const char* str);

void print_uart_short(int ch, uint16_t addr);

void print_uart_int(int ch, uint32_t addr);

void print_uart_addr(int ch, uint64_t addr);

void print_uart_byte(int ch, uint8_t byte);

void write_serial(int ch, char a);

uint8_t read_line_status(int ch);

int is_transmit_empty(int ch);
