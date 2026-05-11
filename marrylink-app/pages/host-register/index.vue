<template>
  <view class="register-container">
    <!-- Step indicator -->
    <view class="step-bar">
      <view class="step" :class="{ active: currentStep >= 1, done: currentStep > 1 }">
        <view class="step-num">1</view>
        <text class="step-text">基本信息</text>
      </view>
      <view class="step-line" :class="{ active: currentStep > 1 }"></view>
      <view class="step" :class="{ active: currentStep >= 2, done: currentStep > 2 }">
        <view class="step-num">2</view>
        <text class="step-text">资料上传</text>
      </view>
      <view class="step-line" :class="{ active: currentStep > 2 }"></view>
      <view class="step" :class="{ active: currentStep >= 3 }">
        <view class="step-num">3</view>
        <text class="step-text">服务信息</text>
      </view>
    </view>

    <!-- Step 1: Basic info -->
    <view class="form-section" v-show="currentStep === 1">
      <view class="section-title">基本信息</view>

      <view class="form-item">
        <view class="form-label"><text>手机号</text><text class="required">*</text></view>
        <input class="form-input" type="number" v-model="form.phone" placeholder="请输入手机号" maxlength="11" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>密码</text><text class="required">*</text></view>
        <input class="form-input" type="password" v-model="form.password" placeholder="请输入密码（至少6位）" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>确认密码</text><text class="required">*</text></view>
        <input class="form-input" type="password" v-model="form.confirmPassword" placeholder="请再次输入密码" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>真实姓名</text><text class="required">*</text></view>
        <input class="form-input" type="text" v-model="form.name" placeholder="请输入真实姓名" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>艺名</text></view>
        <input class="form-input" type="text" v-model="form.stageName" placeholder="请输入艺名（选填）" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>邮箱</text><text class="required">*</text></view>
        <input class="form-input" type="text" v-model="form.email" placeholder="请输入邮箱地址" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>性别</text><text class="required">*</text></view>
        <view class="gender-selector">
          <view class="gender-item" :class="{ active: form.gender === '男' }" @click="form.gender = '男'">
            <text>男</text>
          </view>
          <view class="gender-item" :class="{ active: form.gender === '女' }" @click="form.gender = '女'">
            <text>女</text>
          </view>
        </view>
      </view>

      <view class="form-item">
        <view class="form-label"><text>从业年限</text></view>
        <input class="form-input" type="number" v-model="form.yearsOfExperience" placeholder="请输入从业年限（年）" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>个人标签</text></view>
        <view class="tags-selector">
          <view class="tag-option" v-for="(tag, index) in tagOptions" :key="index"
            :class="{ active: selectedTagCodes.includes(tag.code) }" @click="toggleTag(tag.code)">
            <text>{{ tag.name }}</text>
          </view>
        </view>
        <view class="selected-tags" v-if="selectedTagCodes.length">
          <text class="selected-label">已选: </text>
          <text class="selected-tag" v-for="(code, idx) in selectedTagCodes" :key="idx">{{ getTagNameByCode(code) }}<text v-if="idx < selectedTagCodes.length - 1">、</text></text>
        </view>
        <view class="form-tip">点击选择标签，最多选择5个</view>
      </view>

      <button class="btn-next" @click="nextStep">下一步</button>
    </view>

    <!-- Step 2: Photo & Certificate upload -->
    <view class="form-section" v-show="currentStep === 2">
      <view class="section-title">资料上传</view>

      <view class="form-item">
        <view class="form-label"><text>个人照片</text></view>
        <view class="upload-area" @click="chooseImage('avatar')">
          <image v-if="form.avatar" :src="avatarPreview" class="upload-preview" mode="aspectFill"></image>
          <view v-else class="upload-placeholder">
            <text class="upload-icon">+</text>
            <text class="upload-text">上传个人照片</text>
          </view>
        </view>
        <view class="form-tip">建议上传正面免冠照，支持jpg/png格式</view>
      </view>

      <view class="form-item">
        <view class="form-label"><text>资质证明</text></view>
        <view class="upload-area" @click="chooseImage('certificate')">
          <image v-if="form.certificate" :src="certificatePreview" class="upload-preview" mode="aspectFill"></image>
          <view v-else class="upload-placeholder">
            <text class="upload-icon">+</text>
            <text class="upload-text">上传资质证明</text>
          </view>
        </view>
        <view class="form-tip">可上传从业资格证、荣誉证书等</view>
      </view>

      <view class="btn-group">
        <button class="btn-prev" @click="prevStep">上一步</button>
        <button class="btn-next" @click="nextStep">下一步</button>
      </view>
    </view>

    <!-- Step 3: Service info -->
    <view class="form-section" v-show="currentStep === 3">
      <view class="section-title">服务信息</view>

      <view class="form-item">
        <view class="form-label"><text>服务报价（元/场）</text></view>
        <input class="form-input" type="digit" v-model="form.price" placeholder="请输入每场服务报价" />
      </view>

      <view class="form-item">
        <view class="form-label"><text>服务区域</text></view>
        <input class="form-input" type="text" v-model="serviceAreasInput" placeholder="请输入服务区域，多个用逗号分隔（如：北京,上海）" />
        <view class="form-tip">多个区域请用逗号分隔</view>
      </view>

      <view class="form-item">
        <view class="form-label"><text>个人简介</text></view>
        <textarea class="form-textarea" v-model="form.description" placeholder="请简要介绍您的从业经历和服务特色" maxlength="500" />
        <view class="form-tip">{{ (form.description || '').length }}/500</view>
      </view>

      <view class="agreement">
        <checkbox-group @change="handleAgreementChange">
          <label class="agreement-label">
            <checkbox :checked="agreed" color="#1d4ed8" />
            <text>我已阅读并同意</text>
            <text class="link" @click.stop="showAgreement">《主持人入驻协议》</text>
          </label>
        </checkbox-group>
      </view>

      <view class="btn-group">
        <button class="btn-prev" @click="prevStep">上一步</button>
        <button class="btn-submit" @click="handleSubmit" :disabled="loading || !agreed">
          {{ loading ? '提交中...' : '提交入驻申请' }}
        </button>
      </view>
    </view>
  </view>
</template>

<script>
import { registerHost, uploadHostRegisterFile, getTagList } from '@/api/user'
import { BASE_URL } from '@/utils/request'

export default {
  data() {
    return {
      currentStep: 1,
      form: {
        phone: '',
        password: '',
        confirmPassword: '',
        name: '',
        stageName: '',
        email: '',
        gender: '',
        yearsOfExperience: '',
        avatar: '',
        certificate: '',
        price: '',
        serviceAreas: '',
        description: ''
      },
      serviceAreasInput: '',
      avatarPreview: '',
      certificatePreview: '',
      agreed: false,
      loading: false,
      tagOptions: [],
      selectedTagCodes: []
    }
  },

  async onLoad() {
    try {
      const res = await getTagList('01')
      if (Array.isArray(res)) {
        this.tagOptions = res
      } else if (res && res.data && Array.isArray(res.data)) {
        this.tagOptions = res.data
      }
    } catch (e) {
      console.error('获取标签列表失败:', e)
    }
  },

  methods: {
    // 根据code获取标签名称
    getTagNameByCode(code) {
      const tag = this.tagOptions.find(t => t.code === code)
      return tag ? tag.name : code
    },

    // Step 1 validation
    validateStep1() {
      if (!this.form.phone) {
        uni.showToast({ title: '请输入手机号', icon: 'none' })
        return false
      }
      if (!/^1[3-9]\d{9}$/.test(this.form.phone)) {
        uni.showToast({ title: '手机号格式不正确', icon: 'none' })
        return false
      }
      if (!this.form.password) {
        uni.showToast({ title: '请输入密码', icon: 'none' })
        return false
      }
      if (this.form.password.length < 6) {
        uni.showToast({ title: '密码长度不能少于6位', icon: 'none' })
        return false
      }
      if (this.form.password !== this.form.confirmPassword) {
        uni.showToast({ title: '两次输入的密码不一致', icon: 'none' })
        return false
      }
      if (!this.form.name) {
        uni.showToast({ title: '请输入真实姓名', icon: 'none' })
        return false
      }
      if (!this.form.email) {
        uni.showToast({ title: '请输入邮箱地址', icon: 'none' })
        return false
      }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(this.form.email)) {
        uni.showToast({ title: '邮箱格式不正确', icon: 'none' })
        return false
      }
      if (!this.form.gender) {
        uni.showToast({ title: '请选择性别', icon: 'none' })
        return false
      }
      return true
    },

    // 标签选择
    toggleTag(code) {
      const idx = this.selectedTagCodes.indexOf(code)
      if (idx > -1) {
        this.selectedTagCodes.splice(idx, 1)
      } else {
        if (this.selectedTagCodes.length >= 5) {
          uni.showToast({ title: '最多选择5个标签', icon: 'none' })
          return
        }
        this.selectedTagCodes.push(code)
      }
    },

    nextStep() {
      if (this.currentStep === 1 && !this.validateStep1()) return
      if (this.currentStep < 3) {
        this.currentStep++
      }
    },

    prevStep() {
      if (this.currentStep > 1) {
        this.currentStep--
      }
    },

    // Choose and upload image
    chooseImage(type) {
      uni.chooseImage({
        count: 1,
        sizeType: ['compressed'],
        sourceType: ['album', 'camera'],
        success: (res) => {
          const tempPath = res.tempFilePaths[0]
          // Show local preview immediately
          if (type === 'avatar') {
            this.avatarPreview = tempPath
          } else {
            this.certificatePreview = tempPath
          }
          // Upload to server
          this.uploadFile(tempPath, type)
        }
      })
    },

    uploadFile(filePath, type) {
      uni.showLoading({ title: '上传中...' })

      const uploadType = type === 'avatar' ? 'photo' : 'certificate'

      uni.uploadFile({
        url: BASE_URL + '/auth/register/host/upload?type=' + uploadType,
        filePath: filePath,
        name: 'file',
        success: (res) => {
          const data = JSON.parse(res.data)
          if (data.code === '00000' || data.code === 200) {
            if (type === 'avatar') {
              this.form.avatar = data.data
            } else {
              this.form.certificate = data.data
            }
            uni.showToast({ title: '上传成功', icon: 'success' })
          } else {
            uni.showToast({ title: data.message || '上传失败', icon: 'none' })
          }
        },
        fail: () => {
          uni.showToast({ title: '上传失败', icon: 'none' })
        },
        complete: () => {
          uni.hideLoading()
        }
      })
    },

    handleAgreementChange(e) {
      this.agreed = e.detail.value.length > 0
    },

    showAgreement() {
      uni.showModal({
        title: '主持人入驻协议',
        content: '欢迎入驻MarryLink平台成为主持人。入驻后您的账号将进入待审核状态，平台管理员审核通过后方可正式接单。您需保证所填信息真实有效。',
        showCancel: false
      })
    },

    async handleSubmit() {
      if (!this.agreed) {
        uni.showToast({ title: '请阅读并同意主持人入驻协议', icon: 'none' })
        return
      }

      this.loading = true

      try {
        // Build service areas JSON array
        let serviceAreas = ''
        if (this.serviceAreasInput.trim()) {
          const areas = this.serviceAreasInput.split(',').map(s => s.trim()).filter(s => s)
          serviceAreas = JSON.stringify(areas)
        }

        const submitData = {
          phone: this.form.phone,
          password: this.form.password,
          name: this.form.name,
          stageName: this.form.stageName || null,
          email: this.form.email,
          gender: this.form.gender,
          yearsOfExperience: this.form.yearsOfExperience ? parseInt(this.form.yearsOfExperience) : null,
          avatar: this.form.avatar || null,
          certificate: this.form.certificate || null,
          price: this.form.price ? parseFloat(this.form.price) : null,
          serviceAreas: serviceAreas || null,
          tags: this.selectedTagCodes.length ? this.selectedTagCodes : null,
          description: this.form.description || null
        }

        const res = await registerHost(submitData)

        if (res.code === '00000' || res.code === 200) {
          uni.showModal({
            title: '入驻申请已提交',
            content: res.data || '您的入驻申请正在审核中，请等待管理员审核通过后再登录接单。',
            showCancel: false,
            success: () => {
              uni.navigateBack()
            }
          })
        } else {
          uni.showToast({ title: res.message || '注册失败', icon: 'none' })
        }
      } catch (error) {
        console.error('主持人注册失败:', error)
        uni.showToast({ title: error.message || '注册失败', icon: 'none' })
      } finally {
        this.loading = false
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.register-container {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding: 24rpx 32rpx;
}

.step-bar {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32rpx 0 40rpx;

  .step {
    display: flex;
    flex-direction: column;
    align-items: center;

    .step-num {
      width: 48rpx;
      height: 48rpx;
      border-radius: 50%;
      background-color: #ddd;
      color: #999;
      font-size: 24rpx;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 8rpx;
    }

    .step-text {
      font-size: 22rpx;
      color: #999;
    }

    &.active {
      .step-num {
        background-color: #1d4ed8;
        color: #fff;
      }
      .step-text {
        color: #1d4ed8;
        font-weight: bold;
      }
    }

    &.done {
      .step-num {
        background-color: #22c55e;
        color: #fff;
      }
    }
  }

  .step-line {
    width: 80rpx;
    height: 4rpx;
    background-color: #ddd;
    margin: 0 16rpx;
    margin-bottom: 28rpx;

    &.active {
      background-color: #22c55e;
    }
  }
}

.form-section {
  background-color: #fff;
  border-radius: 24rpx;
  padding: 40rpx 32rpx;
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.05);
}

.section-title {
  font-size: 34rpx;
  font-weight: bold;
  color: #1d4ed8;
  margin-bottom: 32rpx;
  padding-bottom: 16rpx;
  border-bottom: 2rpx solid #f0f0f0;
}

.form-item {
  margin-bottom: 32rpx;

  .form-label {
    display: flex;
    align-items: center;
    margin-bottom: 12rpx;
    font-size: 28rpx;
    color: #333;

    .required {
      color: #ef4444;
      margin-left: 4rpx;
    }
  }

  .form-input {
    width: 100%;
    height: 80rpx;
    padding: 0 24rpx;
    background-color: #f5f7fa;
    border-radius: 12rpx;
    font-size: 28rpx;
    color: #333;
  }

  .form-textarea {
    width: 100%;
    height: 200rpx;
    padding: 20rpx 24rpx;
    background-color: #f5f7fa;
    border-radius: 12rpx;
    font-size: 28rpx;
    color: #333;
  }

  .form-tip {
    margin-top: 8rpx;
    font-size: 22rpx;
    color: #999;
  }
}

.gender-selector {
  display: flex;
  gap: 20rpx;

  .gender-item {
    flex: 1;
    height: 80rpx;
    display: flex;
    align-items: center;
    justify-content: center;
    background-color: #f5f7fa;
    border-radius: 12rpx;
    border: 2rpx solid transparent;
    font-size: 28rpx;
    color: #666;

    &.active {
      background-color: rgba(29, 78, 216, 0.1);
      border-color: #1d4ed8;
      color: #1d4ed8;
      font-weight: bold;
    }
  }
}

.tags-selector {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
  margin-bottom: 16rpx;

  .tag-option {
    padding: 14rpx 30rpx;
    background-color: #f5f7fa;
    border-radius: 32rpx;
    font-size: 24rpx;
    color: #666;
    border: 2rpx solid transparent;

    &.active {
      background-color: rgba(29, 78, 216, 0.1);
      border-color: #1d4ed8;
      color: #1d4ed8;
      font-weight: bold;
    }
  }
}

.selected-tags {
  margin-bottom: 8rpx;
  font-size: 24rpx;
  color: #1d4ed8;

  .selected-label {
    color: #999;
  }
}

.upload-area {
  width: 240rpx;
  height: 240rpx;
  border-radius: 16rpx;
  overflow: hidden;
  border: 2rpx dashed #ccc;
  display: flex;
  align-items: center;
  justify-content: center;

  .upload-preview {
    width: 100%;
    height: 100%;
  }

  .upload-placeholder {
    display: flex;
    flex-direction: column;
    align-items: center;

    .upload-icon {
      font-size: 64rpx;
      color: #ccc;
      line-height: 1;
    }

    .upload-text {
      font-size: 22rpx;
      color: #999;
      margin-top: 8rpx;
    }
  }
}

.agreement {
  margin-bottom: 32rpx;

  .agreement-label {
    display: flex;
    align-items: center;
    font-size: 24rpx;
    color: #666;

    checkbox {
      margin-right: 8rpx;
    }

    .link {
      color: #1d4ed8;
      margin-left: 4rpx;
    }
  }
}

.btn-next, .btn-submit {
  width: 100%;
  height: 88rpx;
  background-color: #1d4ed8;
  color: #fff;
  border: none;
  border-radius: 16rpx;
  font-size: 32rpx;
  font-weight: bold;
  line-height: 88rpx;

  &:disabled {
    opacity: 0.6;
  }
}

.btn-prev {
  flex: 1;
  height: 88rpx;
  background-color: #e5e7eb;
  color: #333;
  border: none;
  border-radius: 16rpx;
  font-size: 32rpx;
  line-height: 88rpx;
}

.btn-group {
  display: flex;
  gap: 20rpx;

  .btn-next, .btn-submit {
    flex: 1;
  }
}
</style>
