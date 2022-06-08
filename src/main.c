#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "mbedtls/rsa.h"
#include "mbedtls/sha256.h"

void read_key(const char *restrict file, char *restrict buf) {
  FILE *restrict fp = fopen(file, "r");
  if (fp == NULL) {
    fprintf(stderr, "Failed to open file %s\n", file);
    return;
  }
  size_t len = 0;

  fseek(fp, 0, SEEK_END);
  len = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  buf = malloc(len + 1);
  if (buf) {
    fread(buf, 1, len, fp);
  }

  fclose(fp);
  buf[len] = '\0';
}

int main(void) {
  const unsigned char input[] = "Hello World!";
  char *pub_key;
  char *priv_key;
  unsigned char hash[32];
  mbedtls_sha256_context sha256_ctx;
  mbedtls_rsa_context rsa_ctx;

  read_key("./src/public.pem", pub_key);
  read_key("./src/private.pem", priv_key);

  mbedtls_sha256_init(&sha256_ctx);
  mbedtls_sha256_starts_ret(&sha256_ctx, 0);
  mbedtls_sha256_update_ret(&sha256_ctx, input, strlen((char *)input));
  mbedtls_sha256_finish_ret(&sha256_ctx, hash);
  printf("%s\n", hash);
  mbedtls_sha256_free(&sha256_ctx);

  mbedtls_rsa_init(&rsa_ctx, MBEDTLS_RSA_PKCS_V21, MBEDTLS_MD_SHA256);
  mbedtls_rsa_rsassa_pss_verify(&rsa_ctx, NULL, NULL, MBEDTLS_RSA_PUBLIC,
                                MBEDTLS_MD_SHA256, 32, hash, sig);

  mbedtls_rsa_free(&rsa_ctx);
  return 0;
}
