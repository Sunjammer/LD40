#ifndef AUDIO_LIB_H
#define AUDIO_LIB_H

#include <inttypes.h>

enum sample_id
{
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_1,
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_2,
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_3,
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_4,
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_5,
    SAMPLE_ID_ENEMY_DIALOGUE_HIGH_6,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_1,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_2,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_3,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_4,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_5,
    SAMPLE_ID_ENEMY_DIALOGUE_LOW_6,

    SAMPLE_ID_EXPLOSION_1,
    SAMPLE_ID_EXPLOSION_2,
    SAMPLE_ID_EXPLOSION_3,

    SAMPLE_ID_SONAR,
    SAMPLE_ID_SONAR_ECHO,

    SAMPLE_ID_TURRET_FIRE,
};

typedef uint32_t sample_id_t;

typedef void context_t;

extern "C" {
    context_t *context_create();
    void context_free(context_t *);

    float context_get_bgm_volume(context_t *);
    void context_set_bgm_volume(context_t *, float);

    void context_play_boot_sequence_sample(context_t *, float); /* volume (recommended 0.8f) */
    void context_play_sample_in_space(context_t *, sample_id_t, float, float); /* sample, relative x, relative y (normalized) */
}

#endif
