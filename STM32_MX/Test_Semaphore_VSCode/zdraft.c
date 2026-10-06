#include <stdint.h>
#include <stdbool.h>

/* driver_sensor.c */
#define SENSOR_CTRL_BASE 0x40024000UL
volatile uint32_t * const SENSOR_CR = (volatile uint32_t *)(SENSOR_CTRL_BASE + 0x00);
volatile uint32_t * const SENSOR_SR = (volatile uint32_t *)(SENSOR_CTRL_BASE + 0x04);
volatile uint32_t * const SENSOR_DR = (volatile uint32_t *)(SENSOR_CTRL_BASE + 0x08);
#define SENSOR_SR_READY_FLAG (1 << 0) // Set by hardware when data ready
#define SENSOR_CR_START_CMD (1 << 2)  // Write 1 to start capture

/* Global tick incremented in SysTick_Handler() every 1 ms */
extern volatile int32_t g_systick_ms;
bool sensor_poll_data(uint32_t timeout_ms, uint32_t *p_out_val) {
  uint32_t start_time = g_systick_ms;
  // Trigger measurement
  *SENSOR_CR |= SENSOR_CR_START_CMD;
  // Wait until hardware signals ready or timeout expires
  while ((*SENSOR_SR & SENSOR_SR_READY_FLAG) == 0) {
    if ((g_systick_ms - start_time) >= timeout_ms) {
      return false; // Hardware failed to respond
    }
  }
  *p_out_val = *SENSOR_DR;
  return true;
}