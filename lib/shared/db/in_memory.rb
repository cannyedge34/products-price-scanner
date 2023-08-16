# frozen_string_literal: true

# we should already have the created items from a items_creator use case.
# Also, it would be good to receive uuids from the frontend, and save records with primary keys with uuids.
# This has a lot of advantages, take a look to https://pawelurbanek.com/uuid-order-rails
# we can keep decoupled the database and use any database
# if the primary keys are uuids instead of autoincremental sql ids.

require 'sequel'
require 'singleton'

module Shared
  module Db
    class InMemory
      include Singleton

      def db
        # connect to an in-memory database
        @db ||= Sequel.sqlite
      end

      def seed
        create_promotions
        create_items
        create_pricing_rules
      end

      private

      def create_promotions
        promotion_records = [
          { name: 'Buy one, get one free', slug: 'buy-one-get-one-free' },
          { name: 'Bulk purchase', slug: 'bulk-purchase' }
        ]
        db.create_table :promotions do
          primary_key :id
          String :name, null: false
          String :slug, null: false
          unique [:name]
        end
        # Create a dataset
        promotions = db[:promotions]
        # Populate the table
        promotion_records.each { |record| promotions.insert(record) }
      end

      def create_items
        promotions = db[:promotions]
        get_one_free_promotion = promotions.where(slug: 'buy-one-get-one-free').first
        bulk_purchase_promotion = promotions.where(slug: 'bulk-purchase').first

        item_records = [
          { code: 'GR1', price: 311_00, promotion_id: get_one_free_promotion[:id] },
          { code: 'SR1', price: 500_00, promotion_id: bulk_purchase_promotion[:id] },
          { code: 'CF1', price: 112_300, promotion_id: bulk_purchase_promotion[:id] },
          { code: 'TFC', price: 550_00, promotion_id: nil }, # there is not promotion for this item
          { code: 'PTC', price: 650_00, promotion_id: nil } # there is not promotion for this item
        ]
        db.create_table :items do
          primary_key :id
          foreign_key :promotion_id, :promotions
          String :code, null: false
          Bignum :price, null: false
        end
        # Create a dataset
        items = db[:items]
        # Populate the table
        item_records.each { |record| items.insert(record) }
      end

      def create_pricing_rules
        db.create_table :pricing_rules do
          primary_key :id
          foreign_key :item_id, :items
          foreign_key :promotion_id, :promotions
          Integer :qty_min, null: false # sqlite does not support range datatype https://www.sqlite.org/datatype3.html
          Integer :qty_max # sqlite does not support range datatype https://www.sqlite.org/datatype3.html
          Bignum :discount, null: false
        end
        # Create a dataset
        pricing_rules = db[:pricing_rules]
        # Populate the table
        pricing_rule_records.each { |record| pricing_rules.insert(record) }
      end

      def pricing_rule_records
        promotions = db[:promotions]
        items = db[:items]

        [
          {
            item_id: items.where(code: 'GR1').first[:id],
            promotion_id: promotions.order(:id).first[:id],
            qty_min: 2,
            qty_max: 2,
            discount: 311_00
          },
          {
            item_id: items.where(code: 'SR1').first[:id],
            promotion_id: promotions.order(:id).last[:id],
            qty_min: 3,
            qty_max: nil,
            discount: 100_000
          },
          {
            item_id: items.where(code: 'CF1').first[:id],
            promotion_id: promotions.order(:id).last[:id],
            qty_min: 3,
            qty_max: nil,
            discount: 333_333
          }
        ]
      end
    end
  end
end
