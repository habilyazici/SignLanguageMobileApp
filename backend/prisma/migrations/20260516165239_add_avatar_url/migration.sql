-- DropIndex
DROP INDEX "PasswordResetToken_email_idx";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "avatarUrl" TEXT;

-- CreateIndex
CREATE INDEX "PasswordResetToken_email_used_expiresAt_idx" ON "PasswordResetToken"("email", "used", "expiresAt");
