FROM node:lts as dependencies
WORKDIR /dashboard
COPY package.json package-lock.json ./
RUN yarn install


FROM node:lts as builder
WORKDIR /dashboard
COPY ./ .
COPY ./.env .
COPY --from=dependencies /dashboard/node_modules ./node_modules
RUN yarn run build
FROM node:lts as runner
WORKDIR /dashboard
ENV NODE_ENV production
COPY --from=builder /dashboard/next.config.js ./
COPY --from=builder /dashboard/public ./public
COPY --from=builder /dashboard/.next ./.next
COPY --from=builder /dashboard/.env ./.env
COPY --from=builder /dashboard/node_modules ./node_modules
COPY --from=builder /dashboard/package.json ./package.json
ENV HOSTNAME="0.0.0.0"
EXPOSE 3009

CMD ["yarn", "start", "-p" , "3000"]