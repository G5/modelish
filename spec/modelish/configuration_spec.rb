# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Modelish::Configuration do
  let(:test_module) do
    module TestModule
      extend Modelish::Configuration
    end
  end

  subject { test_module }

  after { test_module.reset }

  it { is_expected.to respond_to(:configure) }

  context 'with default configuration' do
    its(:ignore_unknown_properties) { is_expected.to eq(false) }
  end

  describe '.configure' do
    subject { test_module.configure(&config_block) }

    context 'with full configuration' do
      let(:config_block) do
        lambda do |config|
          config.ignore_unknown_properties = ignore_unknown_props
        end
      end

      context 'when ignore_unknown_properties is true' do
        let(:ignore_unknown_props) { true }
        its(:ignore_unknown_properties) { is_expected.to eq(true) }
      end

      context 'when ignore_unknown_properties is false' do
        let(:ignore_unknown_props) { false }
        its(:ignore_unknown_properties) { is_expected.to eq(false) }
      end
    end
  end

  describe '.reset' do
    subject { test_module.reset }

    before { test_module.configure { |c| c.ignore_unknown_properties = true } }

    it 'resets the value of ignore_unknown_properties' do
      expect { subject }.to change { test_module.ignore_unknown_properties }
        .from(true).to(false)
    end
  end

  describe 'ignore_unknown_properties!' do
    before { test_module.ignore_unknown_properties = ignore_unknown_props }

    subject { test_module.ignore_unknown_properties! }

    context 'when ignore_unknown_properties is true' do
      let(:ignore_unknown_props) { true }

      it 'does not change the setting' do
        expect { subject }.to_not change { test_module.ignore_unknown_properties }
      end
    end

    context 'when ignore_unknown_properties is false' do
      let(:ignore_unknown_props) { false }

      it 'changes the setting' do
        expect { subject }.to change { test_module.ignore_unknown_properties }
          .from(false).to(true)
      end
    end

    context 'when ignore_unknown_properties is nil' do
      let(:ignore_unknown_props) { nil }

      it 'changes the setting' do
        expect { subject }.to change { test_module.ignore_unknown_properties }
          .from(nil).to(true)
      end
    end
  end

  describe 'raise_errors_on_unknown_properties!' do
    before { test_module.ignore_unknown_properties = ignore_unknown_props }

    subject { test_module.raise_errors_on_unknown_properties! }

    context 'when ignore_unknown_properties is true' do
      let(:ignore_unknown_props) { true }

      it 'changes the setting' do
        expect { subject }.to change { test_module.ignore_unknown_properties }
          .from(true).to(false)
      end
    end

    context 'when ignore_unknown_properties is false' do
      let(:ignore_unknown_props) { false }

      it 'does not change the setting' do
        expect { subject }.to_not change { test_module.ignore_unknown_properties }
      end
    end

    context 'when ignore_unknown_properties is nil' do
      let(:ignore_unknown_props) { nil }

      it 'changes the setting' do
        expect { subject }.to change { test_module.ignore_unknown_properties }
          .from(nil).to(false)
      end
    end
  end
end
