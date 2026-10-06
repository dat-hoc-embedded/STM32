/**
 * @file ring_buffer.h
 * @author your name (you@domain.com)
 * @brief 
 * @version 0.1
 * @date 2026-09-20
 * 
 * @copyright Copyright (c) 2026
 * 
 */
#include "stdint.h"
#include "stdbool.h"

#define RING_BUFFER_SIZE 8
#define RING_BUFFER_MASK (RING_BUFFER_SIZE - 1)

typedef struct
{
    volatile uint8_t head;
    volatile uint8_t tail;
    uint8_t buffer[RING_BUFFER_SIZE];
} ring_buffer_t;

bool ring_buffer_push(ring_buffer_t *b, uint8_t data);
bool ring_buffer_pop(ring_buffer_t *b, uint8_t *data);